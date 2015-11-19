module Verifier
  class ValueRange
    include Enumerable

    attr_reader :upper
    attr_reader :lower

    def initialize(first_end, second_end)
      @lower, @upper = [first_end, second_end].minmax
    end

    def each
      (upper..lower).each { |i| yield i }
    end

    def range
      upper - lower
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
        range == 0 && other.range == 0 && lower == other.lower
      else
        range == 0 && lower == other
      end
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
          ValueRange.new(lower.send(operator, other.lower), upper.send(operator, other.upper))
        else
          ValueRange.new(lower.send(operator, other), upper.send(operator, other))
        end
      end
    end

    # Utilities

    def to_s
      "<ValueRange #{lower}..#{upper}>"
    end

    def to_range
      lower..upper
    end
  end
end
