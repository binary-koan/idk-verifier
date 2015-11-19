module Verifier
  class UnaryOperatorExpression
    include Expression

    def initialize(operator, expression)
      @operator = operator
      @expression = expression
    end

    def static_evaluate(context)
      # ...
    end

    def variable_constraints(context)
      values = @expression.variable_constraints(context)
      values.each { |name, value| values[name] = value.negate }
      values
    end

    def to_s
      # TODO: How to we handle factorial? It needs to be printed at the end.
      "#{@operator}#{@expression}"
    end
  end
end
