class RangeBuilder
  def initialize(expression)
    @expression = expression
  end

  def build
    # get all variables in expression
    # set each variable to NEGATIVE_INFINITY..INFINITY
    # for each logical expression
  end
end

BinaryOperatorExpression#possible_ranges(ranges)
  if lhs.is_a?(VariableExpression) && rhs.is_a?(ConstantExpression)
  if operator == :lt
    ranges[lhs.name] ||= ValueRange.new
    ranges[lhs.name].constrain(:negative_infinity, rhs.value - 1)
