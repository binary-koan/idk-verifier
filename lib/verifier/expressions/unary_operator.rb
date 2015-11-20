module Verifier
  class UnaryOperatorExpression
    include Expression

    attr_reader :operator, :expression

    def initialize(operator, expression)
      @operator = operator
      @expression = expression
    end

    def static_evaluate(context)
      case operator
      when :-
        -@expression.static_evaluate(context)
      when :!
        !@expression.static_evaluate(context)
      end
    end

    def to_s
      # TODO: How to we handle factorial? It needs to be printed at the end.
      "#{@operator}#{@expression}"
    end

    def ==(other)
      if other.is_a?(UnaryOperatorExpression)
        @operator == other.operator && @expression == other.expression
      else
        false
      end
    end
  end
end
