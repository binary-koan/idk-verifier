
require_relative 'token'
require_relative '../verifier/expression'

# TODO: Properly set the precedences.

# Unary operators which prefix things
PREFIX_UNARY_OPERATORS = {
  '!' => { :precedence => 10, :sym => :! }, # Logical not
}

POSTFIX_UNARY_OPERATORS = {
  '!' => { :precedence => 10, :sym => :! }, # Factorial
}

BINARY_OPERATORS = {
  # Arithmetic
  '+' => { :precedence => 10, :sym => :+ }, # Addition
  '-' => { :precedence => 10, :sym => :- }, # Subtraction
  '*' => { :precedence => 10, :sym => :* }, # Multiplication
  '/' => { :precedence => 10, :sym => :/ }, # Division
  '^' => { :precedence => 10, :sym => :^ }, # Power

  # Logical
  '&&' => { :precedence => 10, :sym => :"&&" }, # And
  '||' => { :precedence => 10, :sym => :"||" }, # Or
}

def is_binop(op)
  BINARY_OPERATORS.include?(op)
end

def is_prefix_unary_op(op)
  PREFIX_UNARY_OPERATORS.include?(op)
end

def is_postfix_unary_op(op)
  POSTFIX_UNARY_OPERATORS.include?(op)
end

def precedence_binop(op)
  if op.nil? || !op.is_symbol?
    return -1
  end

  info = BINARY_OPERATORS[op.value]

  if info
    info[:precedence]
  else
    -1
  end
end

class Parser
  def initialize(characters)
    @tokenizer = Tokenizer.new(characters)
  end


  def parse_expression
    lhs = parse_primary_expression

    parse_binop_rhs(lhs, 0) if lhs
  end

  private

  def parse_primary_expression
    first_token = @tokenizer.next

    return nil if first_token.nil?

    if first_token.is_word?
      Verifier::VariableExpression.new(first_token.value)
    elsif first_token.is_string?
      fail # we don't support strings yet
    elsif first_token.is_integer?
      Verifier::ConstantExpression.new(first_token.value)
    elsif first_token == '('
      parse_parenthesized_expression
    else
      fail
    end

  end

  def parse_parenthesized_expression
    inner = parse_expression
    expect(')')
    inner
  end

  def parse_binop_rhs(lhs, min_precedence)
    lookahead = @tokenizer.peek

    while precedence_binop(lookahead) >= min_precedence do

      op = lookahead
      @tokenizer.next
      rhs = parse_primary_expression
      lookahead = @tokenizer.peek

      while lookahead != nil && precedence_binop(lookahead) > precedence_binop(op) do
        rhs = parse_binop_rhs(rhs, precedence_binop(lookahead))
        lookahead = @tokenizer.peek
      end
      lhs = Verifier::BinaryOperatorExpression.new(BINARY_OPERATORS[op.value][:sym], lhs, rhs)
    end
    lhs
  end

  def expect(value)
    token = @tokenizer.next
    fail if token != value
  end
end
