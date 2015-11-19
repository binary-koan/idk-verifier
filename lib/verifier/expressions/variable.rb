module Verifier
  class VariableExpression
    include Expression

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def static_evaluate(context)
      if context.has_key?(@name)
        context[@name]
      else
        fail(UndefinedVariableError, "You can't use #{@name} before it's defined")
      end
    end

    def to_s
      @name
    end

    def ==(other)
      if self.is_a?(VariableExpression) && other.is_a?(VariableExpression)
        @name == other.name
      else
        false
      end
    end
  end

  class UndefinedVariableError < StandardError
  end
end
