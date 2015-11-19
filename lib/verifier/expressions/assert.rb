module Verifier
  class AssertionError < StandardError
  end

  class AssertExpression
    include Expression

    attr_reader :expression

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

    def ==(other)
      if other.is_a?(AssertExpression)
        @expression == other.expression
      else
        false
      end
    end
  end
end
