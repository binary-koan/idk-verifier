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
      @expression.assign(context, lhs_values)
      rhs_values = rhs.possible_variable_values(context)
      values = @expression.combine_values(lhs_values, rhs_values)
      @expression.assign(context, values)
    end
  end

  class ComparisonOperatorStrategy < BinaryOperatorStrategy
    def possible_variable_values(context)
      simple_variable_constraint || {}
    end

    private

    def simple_variable_constraint
      return unless lhs.is_a?(VariableExpression) &&
        rhs.is_a?(ConstantExpression)

      value = case operator
      when :<
        IndefiniteRange.new(upper: rhs.value - 1)
      when :<=
        IndefiniteRange.new(upper: rhs.value)
      when :==
        DefiniteRange.new(rhs.value, rhs.value)
      when :>=
        IndefiniteRange.new(lower: rhs.value)
      when :>
        IndefiniteRange.new(lower: rhs.value + 1)
      end

      { lhs.name => value }
    end
  end

  class ArithmeticOperatorStrategy < BinaryOperatorStrategy
    def possible_variable_values(context)
      #TODO something sensible so you can have: expect x where x > 1 + 2
      {}
    end
  end
end
