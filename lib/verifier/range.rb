module Verifier
  class UnionRange
    def initialize(*ranges)
      @ranges = ranges
    end

    # ...
  end

  class ValueRange
    attr_reader :upper
    attr_reader :lower

    def initialize(upper: Float::INFINITY, lower: -Float::INFINITY)
      @upper = upper
      @lower = lower
    end

    def constrain(other)
      new_upper = [upper, other.upper].min
      new_lower = [lower, other.lower].max
      ValueRange.new(upper: new_upper, lower: new_lower)
    end

    def range
      upper - lower if upper && lower
    end

    # Comparisons

    def <(other)
      self <= (other - 1)
    end

    def <=(other)
      if other.is_a?(ValueRange)
        upper <= other.lower
      else
        upper <= other
      end
    end

    def >(other)
      self >= (other + 1)
    end

    def >=(other)
      if other.is_a?(ValueRange)
        lower >= other.upper
      else
        lower >= other
      end
    end

    def ==(other)
      if other.is_a?(ValueRange)
        lower == other.lower && upper == other.upper
      else
        range == 0 && lower == other
      end
    end

    def strictly_equal?(other)
      range == 0 && other.range == 0 && lower == other.lower
    end

    def !=(other)
      outside?(other)
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
