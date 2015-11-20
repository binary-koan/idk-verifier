module Verifier
  POSITIVE_INFINITY = Float::INFINITY
  NEGATIVE_INFINITY = -Float::INFINITY

  class UnionRange
    attr_reader :ranges

    def initialize(*ranges, simple: false)
      @ranges = ranges.map { |range| range.is_a?(UnionRange) ? range.ranges : range }.flatten
      @simple = simple
    end

    def simple?
      @simple
    end

    def simplify
      return self if simple?

      new_ranges = merge_overlapping_ranges(ranges.map(&:to_range))
      new_ranges.map! { |ruby_range| ValueRange.new(lower: ruby_range.begin, upper: ruby_range.end) }

      if new_ranges.size == 1
        new_ranges[0]
      else
        UnionRange.new(*new_ranges, simple: true)
      end
    end

    def &(other)
      if other.is_a?(UnionRange)
        fail("Can't intersect union ranges right now ...") #TODO
      else
        UnionRange.new(*ranges.map { |range| range & other }.compact, simple: @simple)
      end
    end

    def range
      [ranges.map(&:lower).min, ranges.map(&:upper).max]
    end

    [:<, :<=, :>, :>=, :==, :strictly_equal?, :outside?].each do |operator|
      define_method(operator) do |other|
        ranges.all? { |range| range.send(operator, other) }
      end
    end

    def -@
      # Quite likely wrong
      UnionRange.new(*ranges.map { |range| -range })
    end

    [:+, :-, :*, :/].each do |operator|
      define_method(operator) do |other|
        UnionRange.new(*ranges.map { |range| range.send(operator, other) }, simple: @simple)
      end
    end

    def to_s
      ranges.sort.join("|")
    end

    private

    def ranges_overlap?(a, b)
      a.include?(b.begin) || b.include?(a.begin)
    end

    def merge_ranges(a, b)
      [a.begin, b.begin].min..[a.end, b.end].max
    end

    def merge_overlapping_ranges(ranges)
      ranges.sort_by(&:begin).inject([]) do |ranges, range|
        if !ranges.empty? && ranges_overlap?(ranges.last, range)
          ranges[0...-1] + [merge_ranges(ranges.last, range)]
        else
          ranges + [range]
        end
      end
    end
  end

  class ValueRange
    include Comparable

    attr_reader :upper
    attr_reader :lower

    def initialize(upper: Float::INFINITY, lower: -Float::INFINITY)
      @upper = upper
      @lower = lower
    end

    def simplify
      self
    end

    def &(other)
      if other.is_a?(UnionRange)
        return other & self
      elsif outside?(other)
        return nil
      end

      new_upper = [upper, other.upper].min
      new_lower = [lower, other.lower].max
      ValueRange.new(upper: new_upper, lower: new_lower)
    end

    def range
      upper - lower if upper && lower
    end

    # Comparisons

    # This has unexpected behaviour, eg. value_range(upper: 900) == value_range(upper: 1000)
    # Would be good to make it sensible - can it be done without breaking the verifier?
    def <=>(other)
      other = ValueRange.new(upper: other, lower: other) unless other.is_a?(ValueRange)

      if upper < other.lower
        -1
      elsif lower > other.upper
        1
      else
        0
      end
    end

    def strictly_equal?(other)
      range == 0 && other.range == 0 && lower == other.lower
    end

    def outside?(other)
      upper < other.lower || lower > other.upper
    end

    # Arithmetic

    def inverse
      if lower == NEGATIVE_INFINITY
        ValueRange.new(lower: upper == POSITIVE_INFINITY ? NEGATIVE_INFINITY : upper)
      elsif upper == POSITIVE_INFINITY
        ValueRange.new(upper: lower == NEGATIVE_INFINITY ? POSITIVE_INFINITY : lower)
      else
        UnionRange.new(ValueRange.new(upper: lower + 1), ValueRange.new(lower: upper - 1))
      end
    end

    def -@
      # This may be wrong ...
      ValueRange.new(upper: -lower, lower: -upper)
    end

    [:+, :-, :*, :/].each do |operator|
      define_method(operator) do |other|
        if other.is_a?(ValueRange)
          # Inefficient but effective
          minmax = calculated_combinations(operator, other).minmax
          ValueRange.new(lower: minmax[0], upper: minmax[1])
        else
          ValueRange.new(
            lower: lower.send(operator, other), upper: upper.send(operator, other)
          )
        end
      end
    end

    # Utilities

    def to_s
      "#{lower}..#{upper}"
    end

    def to_range
      lower..upper
    end

    private

    def calculated_combinations(operator, other)
      [
        lower.send(operator, other.lower),
        lower.send(operator, other.upper),
        upper.send(operator, other.lower),
        upper.send(operator, other.upper)
      ]
    end
  end
end
