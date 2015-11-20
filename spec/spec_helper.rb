require 'simplecov'
SimpleCov.start

require_relative "../lib/verifier/expression"
require_relative "../lib/verifier/range"
require_relative "../lib/verifier/scope"

RSpec.configure do
  # Expression builders
  def expectation(names, expr)
    Verifier::ExpectExpression.new(names, expr)
  end

  def assertion(expr)
    Verifier::AssertExpression.new(expr)
  end

  def assignment(name, expr)
    Verifier::AssignmentExpression.new(name, expr)
  end

  def bin_op(operator, lhs, rhs)
    Verifier::BinaryOperatorExpression.new(operator, lhs, rhs)
  end

  def variable(name)
    Verifier::VariableExpression.new(name)
  end

  def constant(value)
    Verifier::ConstantExpression.new(value)
  end

  def if_condition(expression, true_expressions, false_expressions)
    Verifier::IfExpression.new(
      Verifier::IfBranch.if(expression, true_expressions),
      Verifier::IfBranch.else(false_expressions)
    )
  end

  # Value builders
  def value_range(**kwargs)
    Verifier::ValueRange.new(**kwargs)
  end

  def union_range(*args)
    Verifier::UnionRange.new(*args)
  end
end
