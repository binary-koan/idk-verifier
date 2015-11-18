module Verifier
  class ConstantTerm
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def combine(other)
      ConstantTerm.new(value + other.value)
    end
  end

  class VariableTerm
    def initialize(variable, multiplier)
      @variable = variable
      @multiplier = multiplier
    end

    def name
      @variable.name
    end
  end
end
