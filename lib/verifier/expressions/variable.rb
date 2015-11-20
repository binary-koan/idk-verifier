module Verifier
  class VariableExpression
    include Expression

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def static_evaluate(context)
      if context.has_key?(@name)
        context[@name] = context[@name].simplify
      else
        context[@name] = ValueRange.new
      end
    rescue => e
      p context
      raise e
    end

    def to_s
      @name
    end

    def inspect
      @name
    end

    def ==(other)
      if self.is_a?(VariableExpression) && other.is_a?(VariableExpression)
        @name == other.name
      else
        @name == other
      end
    end
  end

  class UndefinedVariableError < StandardError
  end
end
