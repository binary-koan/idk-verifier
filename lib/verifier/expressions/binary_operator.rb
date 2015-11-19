module Verifier
  class BinaryOperatorExpression
    include Expression

    def initialize(operator, lhs, rhs)
      @operator = operator
      @lhs = lhs
      @rhs = rhs
    end

    def static_evaluate(context)
      case @operator
      when :and
        @lhs.static_evaluate(context) && @rhs.static_evaluate(context)
      when :or
        @lhs.static_evaluate(context) || @rhs.static_evaluate(context)
      # ...
      end
    end

    def possible_variable_values(context)
      case @operator
      when :and
        intersect_variable_values
      end
    end

    def to_s
      "#{@lhs} #{@operator} #{@rhs}"
    end

    private

    def intersect_variable_values
      lhs_values = @lhs.possible_variable_values(context)
      assign(context, lhs_values)
      rhs_values = @rhs.possible_variable_values(context)
      values = combine_values(lhs_values, rhs_values)
      assign(context, values)
    end
  end
end
