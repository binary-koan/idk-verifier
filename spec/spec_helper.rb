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

  # Value builders
  def value_range(**kwargs)
    Verifier::ValueRange.new(**kwargs)
  end
end
