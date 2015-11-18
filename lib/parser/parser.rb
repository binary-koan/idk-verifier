
require_relative 'token'
require_relative '../verifier/expression'

# TODO: Properly set the precedences.

# Unary operators which prefix things
PREFIX_UNARY_OPERATORS = {
  '!' => { :precedence => 10, :sym => :not }, # Logical not
}

POSTFIX_UNARY_OPERATORS = {
  '!' => { :precedence => 10, :sym => :fac }, # Factorial
}

BINARY_OPERATORS = {
  # Arithmetic
  '+' => { :precedence => 10, :sym => :add }, # Addition
  '-' => { :precedence => 10, :sym => :sub }, # Subtraction
  '*' => { :precedence => 10, :sym => :mul }, # Multiplication
  '/' => { :precedence => 10, :sym => :div }, # Division
  '^' => { :precedence => 10, :sym => :pow }, # Power

  # Logical
  '&&' => { :precedence => 10, :sym => :and }, # And
  '||' => { :precedence => 10, :sym => :or  }, # Or
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
  if !op.is_symbol?
    return -1
  end

  info = BINARY_OPERATORS[op]

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
    parse_binop_rhs(parse_primary_expression, 0)
  end

  private

  def parse_primary_expression
    first_token = @tokenizer.next
    puts "first_token: #{first_token}"

    if first_token.is_word?
      VariableExpression.new(first_token.value)
    elsif first_token.is_string?
      fail # we don't support strings yet
    elsif first_token.is_integer?
      Verifier::ConstantExpression.new(first_token.value)
    else
      fail
    end

  end

  def parse_binop_rhs(lhs, min_precedence)
    lookahead = @tokenizer.peek


    puts "lookahead: #{lookahead.class}"
    while precedence_binop(lookahead) >= min_precedence do
      op = lookahead
      @tokenizer.next
      rhs = parse_primary_expression
      lookahead = @tokenizer.peek

      while precedence_binop(lookahead) > precedence_binop(op) do
        rhs = parse_binop_rhs(rhs, precedence_binop(lookahead))
        lookahead = @tokenizer.peek
      end
      lhs = BinaryOperatorExpression.new(BINARY_OPERATORS[op.value].sym, lhs, rhs)
    end
    lhs
  end
end
