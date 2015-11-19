module Verifier
  class ExpectExpression
    include Expression

    def initialize(names, expression)
      @names = names
      @expression = expression
    end

    def static_evaluate(context)
      context.merge!(variable_constraints(context))
    end

    def variable_constraints(context)
      @expression.variable_constraints(context)
    end

    def to_s
      "expect #{@names.join(', ')} where #{@expression}"
    end
  end
end
