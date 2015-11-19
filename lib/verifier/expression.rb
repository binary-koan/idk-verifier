module Verifier
  class ExpectExpression
    def initialize(names, expression)
      @names = names
      @expression = expression
    end

    def static_evaluate(locals)
      # What to do here?
    end

    def to_s
      "expect #{@names.join(', ')} where #{@expression}"
    end
  end

  class AssertExpression
    def initialize(expression)
      @expression = expression
    end

    def static_evaluate(locals)
      result = @expression.static_evaluate(locals)
      fail(VerificationError, "Assertion does not hold") unless result
    end

    def to_s
      "assert #{@expression}"
    end
  end

  class AssignmentExpression
    def initialize(name, expression)
      @name = name
      @expression = expression
    end

    def static_evaluate(locals)
      locals[@name] = @expression.static_evaluate(locals)
    end

    def to_s
      "#{@name} = #{@expression}"
    end
  end

  class BinaryOperatorExpression
    def initialize(operator, lhs, rhs)
      @operator = operator
      @lhs = lhs
      @rhs = rhs
    end

    def static_evaluate(locals)
      case @operator
      when :and
        @lhs.static_evaluate(locals) && @rhs.static_evaluate(locals)
      when :or
        @lhs.static_evaluate(locals) || @rhs.static_evaluate(locals)
      # ...
      end
    end

    def to_s
      "#{@lhs} #{@operator} #{@rhs}"
    end
  end

  class UnaryOperatorExpression
    def initialize(operator, expression)
      @operator = operator
      @expression = expression
    end

    def static_evaluate(locals)
      # ...
    end

    def to_s
      # TODO: How to we handle factorial? It needs to be printed at the end.
      "#{@operator}#{@expression}"
    end
  end

  class VariableExpression
    def initialize(name)
      @name = name
    end

    def static_evaluate(locals)
      locals[@name]
    end

    def to_s
      @name
    end
  end

  class ConstantExpression
    def initialize(value)
      @value = value
    end

    def static_evaluate(locals)
      value
    end

    def to_s
      @value.to_s
    end
  end
end
