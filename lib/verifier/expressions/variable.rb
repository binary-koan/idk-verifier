module Verifier
  class VariableExpression
    include Expression

    def initialize(name)
      @name = name
    end

    def static_evaluate(context)
      context[@name]
    end

    def to_s
      @name
    end
  end
end
