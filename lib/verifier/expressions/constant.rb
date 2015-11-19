module Verifier
  class ConstantExpression
    include Expression

    attr_reader :value

    def initialize(value)
      @value = value
    end

    def static_evaluate(context)
      value
    end

    def to_s
      @value.to_s
    end

    def ==(other)
        @value == other
    end
  end
end
