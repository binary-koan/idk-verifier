module Verifier
  class BinaryOperatorExpression
    include Expression

    attr_reader :lhs, :rhs, :operator

    def initialize(operator, lhs, rhs)
      @operator = operator
      @lhs = lhs
      @rhs = rhs

      @evaluation_strategy = case operator
      when :"&&" then AndOperatorStrategy.new(self)
      when :"||" then OrOperatorStrategy.new(self)
      when :<, :<=, :==, :>, :>= then ComparisonOperatorStrategy.new(self)
      when :+, :-, :*, :/ then ArithmeticOperatorStrategy.new(self)
      end
    end

    def static_evaluate(context)
      @evaluation_strategy.static_evaluate(context)
    end

    def variable_constraints(context)
      @evaluation_strategy.variable_constraints(context)
    end

    def to_s
      "#{@lhs} #{@operator} #{@rhs}"
    end

    def ==(other)
      if self.is_a?(BinaryOperatorExpression) && other.is_a?(BinaryOperatorExpression)
        (@operator == other.operator) &&
        (@lhs == other.lhs) &&
        (@rhs == other.rhs)
      else
        false
      end
    end
  end

  # Strategies for evaluating the expression

  class BinaryOperatorStrategy
    def initialize(expression)
      @expression = expression
    end

    [:operator, :lhs, :rhs].each do |method|
      define_method(method) { @expression.send(method) }
    end

    def static_evaluate(context)
      lhs_value, rhs_value = operand_values(context)
      lhs_value.send(operator, rhs_value)
    end

    private

    def operand_values(context)
      [lhs.static_evaluate(context), rhs.static_evaluate(context)]
    end
  end

  class AndOperatorStrategy < BinaryOperatorStrategy
    def static_evaluate(context)
      lhs.static_evaluate(context) && rhs.static_evaluate(context)
    end

    def variable_constraints(context)
      lhs_constraints = lhs.variable_constraints(context)
      rhs_constraints = rhs.variable_constraints(context.merge(lhs_constraints))
      combined_constraints(lhs_constraints, rhs_constraints)
    end

    private

    def combined_constraints(first_values, second_values)
      first_values.merge(second_values) do |name, value1, value2|
        if value1 && value2
          value1 & value2
        else
          value1 || value2
        end
      end
    end
  end

  class OrOperatorStrategy < BinaryOperatorStrategy
    def static_evaluate(context)
      lhs.static_evaluate(context) || rhs.static_evaluate(context)
    end

    def variable_constraints(context)
      lhs_constraints = lhs.variable_constraints(context)
      rhs_constraints = rhs.variable_constraints(context.merge(lhs_constraints))
      combined_constraints(lhs_constraints, rhs_constraints)
    end

    private

    def combined_constraints(first_values, second_values)
      first_values.merge(second_values) do |name, value1, value2|
        if value1 && value2
          UnionRange.new(value1, value2)
        else
          value1 || value2
        end
      end
    end
  end

  class ComparisonOperatorStrategy < BinaryOperatorStrategy
    def static_evaluate(context)
      if operator == :==
        lhs_value, rhs_value = operand_values(context)
        lhs_value.strictly_equal?(rhs_value)
      elsif operator == :!=
        lhs_value, rhs_value = operand_values(context)
        lhs_value.outside?(rhs_value)
      else
        super
      end
    end

    def variable_constraints(context)
      simple_variable_constraint(context) || {}
    end

    private

    def simple_variable_constraint(context)
      return unless lhs.is_a?(VariableExpression)

      value = rhs.static_evaluate(context)
      bounds = case operator
      when :<
        ValueRange.new(upper: value.lower - 1)
      when :<=
        ValueRange.new(upper: value.lower)
      when :==
        ValueRange.new(lower: value.lower, upper: value.upper)
      when :>=
        ValueRange.new(lower: value.upper)
      when :>
        ValueRange.new(lower: value.upper + 1)
      end

      { lhs.name => bounds }
    end
  end

  class ArithmeticOperatorStrategy < BinaryOperatorStrategy
  end
end
