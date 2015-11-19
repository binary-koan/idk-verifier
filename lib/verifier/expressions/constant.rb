module Verifier
  class ConstantExpression
    include Expression

    def initialize(value)
      @value = value
    end

    def static_evaluate(context)
      value
    end

    def to_s
      @value.to_s
    end
  end
end
