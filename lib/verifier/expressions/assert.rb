module Verifier
  class AssertionError < StandardError
  end

  class AssertExpression
    include Expression

    def initialize(expression)
      @expression = expression
    end

    def static_evaluate(context)
      result = @expression.static_evaluate(context)
      fail(AssertionError, "Assertion does not hold: #{self}") unless result
    end

    def to_s
      "assert #{@expression}"
    end
  end
end
