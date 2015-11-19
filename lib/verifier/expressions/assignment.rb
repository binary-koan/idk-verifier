module Verifier
  class AssignmentExpression
    include Expression

    def initialize(name, expression)
      @name = name
      @expression = expression
    end

    def static_evaluate(context)
      context[@name] = @expression.static_evaluate(context)
    end

    def to_s
      "#{@name} = #{@expression}"
    end
  end
end
