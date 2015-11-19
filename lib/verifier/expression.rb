module Verifier
  module Expression
    def static_evaluate(context)
    end

    def possible_variable_values(context)
      {}
    end

    def assign(context, values)
      values.each do |name, value|
        context[name] = value
      end
    end

    def combine_values(first_values, second_values)
      first_values.merge(second_values) do |name, value1, value2|
        if value1 && value2
          value1.constrain(value2)
        else
          value1 || value2
        end
      end
    end
  end
end

require_relative "expressions/assert"
require_relative "expressions/assignment"
require_relative "expressions/binary_operator"
require_relative "expressions/constant"
require_relative "expressions/expect"
require_relative "expressions/unary_operator"
require_relative "expressions/variable"
