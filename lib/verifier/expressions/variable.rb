module Verifier
  class VariableExpression
    include Expression

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def static_evaluate(context)
      context[@name]
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
end
