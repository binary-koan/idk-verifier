module Verifier
  class ExpectExpression
    include Expression

    def initialize(names, expression)
      @names = names
      @expression = expression
    end

    def static_evaluate(context)
      assign(context, possible_variable_values)
    end

    def possible_variable_values(context)
      @expression.possible_variable_values(context)
    end

    def to_s
      "expect #{@names.join(', ')} where #{@expression}"
    end
  end
end
