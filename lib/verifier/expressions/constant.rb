module Verifier
  class ConstantExpression
    include Expression

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def static_evaluate(context)
      ValueRange.new(lower: value, upper: value)
    end

    def to_s
      @value.to_s
    end

    def ==(other)
      if other.is_a?(Integer)
        @value == other
      else
        @value == other.value
      end
    end
  end
end
