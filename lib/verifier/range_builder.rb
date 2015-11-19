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

BinaryOperatorExpression#possible_ranges(locals)
  if lhs.is_a?(VariableExpression)
  if operator == :lt
    { rhs.name => DefiniteRange.new(:negative_infinity, rhs.possible_ranges(locals) - 1) }
