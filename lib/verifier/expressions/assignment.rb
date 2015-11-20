module Verifier
  class AssignmentExpression
    include Expression

    attr_reader :name, :expression

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

    def inspect
      "#{@name.inspect} = #{@expression.inspect}"
    end

    def ==(other)
      if other.is_a?(AssignmentExpression)
        @name == other.name
        @expression == other.expression
      end
    end
  end
end
