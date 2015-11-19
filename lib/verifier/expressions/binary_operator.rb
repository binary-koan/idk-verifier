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
      when :<, :<=, :==, :>, :>= then ComparisonOperatorStrategy.new(self)
      when :+, :-, :*, :/ then ArithmeticOperatorStrategy.new(self)
      end
    end

    def static_evaluate(context)
      @evaluation_strategy.static_evaluate(context)
    end

    def possible_variable_values(context)
      @evaluation_strategy.possible_variable_values(context)
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
      lhs_value = lhs.static_evaluate(context)
      rhs_value = rhs.static_evaluate(context)
      lhs_value.send(@expression.operator, rhs_value)
    end
  end

  class AndOperatorStrategy < BinaryOperatorStrategy
    def static_evaluate(context)
      lhs.static_evaluate(context) && rhs.static_evaluate(context)
    end

    def possible_variable_values(context)
      lhs_values = lhs.possible_variable_values(context)
      context.assign(lhs_values)
      rhs_values = rhs.possible_variable_values(context)
      context.assign(combine_values(lhs_values, rhs_values))
    end

    private

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

  class ComparisonOperatorStrategy < BinaryOperatorStrategy
    def possible_variable_values(context)
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
