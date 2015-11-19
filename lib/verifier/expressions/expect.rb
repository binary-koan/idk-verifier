module Verifier
  class ExpectExpression
    include Expression

    attr_reader :names, :expression

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

    def ==(other)
      if other.is_a?(ExpectExpression)
        @names == other.names
        @expression == other.expression
      else
        false
      end
    end
  end
end
