require_relative "range"

module Verifier
  module Expression
    def static_evaluate(context)
    end

    def variable_constraints(context)
      {}
    end
  end
end

require_relative "expressions/assert"
require_relative "expressions/assignment"
require_relative "expressions/binary_operator"
require_relative "expressions/constant"
require_relative "expressions/expect"
require_relative "expressions/if"
require_relative "expressions/while"
require_relative "expressions/unary_operator"
require_relative "expressions/variable"
