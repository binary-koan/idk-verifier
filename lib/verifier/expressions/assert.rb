module Verifier
  class AssertExpression
    include Expression

    def initialize(expression)
      @expression = expression
    end

    def static_evaluate(context)
      result = @expression.static_evaluate(context)
      fail(VerificationError, "Assertion does not hold") unless result
    end

    def to_s
      "assert #{@expression}"
    end
  end
end
