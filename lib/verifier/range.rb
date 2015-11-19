module Verifier
  class UnionRange
    attr_reader :ranges

    def initialize(*ranges)
      @ranges = ranges
    end

    def &(other)
      # Do something ...
    end

    def range
      [ranges.map(&:lower).min, ranges.map(&:upper).max]
    end

    [:<, :<=, :>, :>=, :==, :strictly_equal?, :outside?].each do |operator|
      define_method(operator) do |other|
        ranges.all? { |range| range.send(operator, other) }
      end
    end

    #TODO unary negation

    [:+, :-, :*, :/].each do |operator|
      define_method(operator) do |other|
        ranges.map { |range| range.send(operator, other) }
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

    def &(other)
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
      if other.is_a?(ValueRange)
        if upper < other.lower then -1
        elsif lower > other.upper then 1
        else 0
        end
      else
        if upper < other then -1
        elsif lower > other then 1
        else 0
        end
      end
    end

    def strictly_equal?(other)
      range == 0 && other.range == 0 && lower == other.lower
    end

    def outside?(other)
      upper < other.lower || lower > other.upper
    end

    # Arithmetic

    def -@
      # This is probably wrong ...
      ValueRange.new(-lower, -upper)
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
