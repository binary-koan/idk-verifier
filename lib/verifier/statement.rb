module Verifier
  class Statement
    def valid?
      true
    end

    def static_evaluate(locals)
      locals
    end
  end

  class AssignmentStatement
    def initialize(name, expression)
    end

    def static_evaluate(locals)
      if locals[name]
        locals[name] = locals[name].with_value(expression)
      end
      locals
    end
  end

  class AssertionStatement
    def initialize(expression)
      @expression = expression
    end

    def valid?
      @expression.valid?
    end
  end
end
