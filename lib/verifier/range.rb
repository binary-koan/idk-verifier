module Verifier
  class ValueRange
  end

  class UnionRange < ValueRange
    def initialize(*ranges)
      @ranges = ranges
    end

    # ...
  end

  class IndefiniteRange < ValueRange
    attr_reader :upper
    attr_reader :lower

    def initialize(upper: nil, lower: nil)
      @upper = upper
      @lower = lower
    end

    def constrain(other)
      if upper && other.upper
        new_upper = [upper, other.upper].max
      else
        new_upper = upper || other.upper
      end

      if lower && other.lower
        new_lower = [lower, other.lower].min
      else
        new_lower = lower || other.lower
      end

      if new_upper && new_lower
        DefiniteRange.new(new_upper, new_lower)
      else
        IndefiniteRange.new(upper: new_upper, lower: new_lower)
      end
    end
  end

  class DefiniteRange < ValueRange
    attr_reader :upper
    attr_reader :lower

    def initialize(first_end, second_end)
      @lower, @upper = [first_end, second_end].minmax
    end

    def range
      upper - lower
    end

    # Comparisons

    def <(other)
      self <= (other - 1)
    end

    def <=(other)
      if other.is_a?(DefiniteRange)
        upper <= other.lower
      else
        upper <= other
      end
    end

    def >(other)
      self >= (other + 1)
    end

    def >=(other)
      if other.is_a?(DefiniteRange)
        lower >= other.upper
      else
        lower >= other
      end
    end

    def ==(other)
      if other.is_a?(DefiniteRange)
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
      DefiniteRange.new(-lower, -upper)
    end

    [:+, :-, :*, :/].each do |operator|
      define_method(operator) do |other|
        if other.is_a?(DefiniteRange)
          # Inefficient but effective
          DefiniteRange.new(*calculated_combinations(operator, other).minmax)
        else
          DefiniteRange.new(lower.send(operator, other), upper.send(operator, other))
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
