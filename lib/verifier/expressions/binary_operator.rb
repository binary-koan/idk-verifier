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
  end

  class AndOperatorStrategy
    def initialize(expression)
      @expression = expression
    end

    def static_evaluate(context)
      @expression.lhs.static_evaluate(context) && @expression.rhs.static_evaluate(context)
    end

    def possible_variable_values(context)
      lhs_values = @expression.lhs.possible_variable_values(context)
      @expression.assign(context, lhs_values)
      rhs_values = @expression.rhs.possible_variable_values(context)
      values = @expression.combine_values(lhs_values, rhs_values)
      @expression.assign(context, values)
    end
  end

  class ComparisonOperatorStrategy
    def initialize(expression)
      @expression = expression
    end

    def static_evaluate(context)
      lhs_value = @expression.lhs.static_evaluate(context)
      rhs_value = @expression.rhs.static_evaluate(context)
      lhs_value.send(@expression.operator, rhs_value)
    end

    def possible_variable_values(context)
      simple_variable_constraint
    end

    private

    def simple_variable_constraint
      return unless @expression.lhs.is_a?(VariableExpression) &&
        @expression.rhs.is_a?(ConstantExpression)

      value = case @expression.operator
      when :<
        IndefiniteRange.new(upper: @expression.rhs.value - 1)
      when :<=
        IndefiniteRange.new(upper: @expression.rhs.value)
      when :==
        DefiniteRange.new(@expression.rhs.value, @expression.rhs.value)
      when :>=
        IndefiniteRange.new(lower: @expression.rhs.value)
      when :>
        IndefiniteRange.new(lower: @expression.rhs.value + 1)
      end

      { @expression.lhs.name => value }
    end
  end
end
