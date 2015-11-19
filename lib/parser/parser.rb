
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

  # Comparisons
  '<'  => { :precedence => 10, :sym => :< }, # Less than
  '<=' => { :precedence => 10, :sym => :<= }, # Less than or equal to
  '>'  => { :precedence => 10, :sym => :> }, # Greater than
  '>=' => { :precedence => 10, :sym => :>= }, # Greater than or equal to
  '==' => { :precedence => 10, :sym => :== }, # Equals
  '!=' => { :precedence => 10, :sym => :!= }, # Not-equal-to

  # Logical
  '&&' => { :precedence => 10, :sym => :"&&" }, # And
  '||' => { :precedence => 10, :sym => :"||" }, # Or
}

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
  def self.parse_file(filename)
    parser = Parser.new(File.read(filename).chars.each)
    expressions = []
    while (expression = parser.parse_expression)
      expressions << expression
    end

    Verifier::Scope.new(expressions)
  end

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
      parse_word_expression(first_token)
    elsif first_token.is_string?
      fail # we don't support strings yet
    elsif first_token.is_integer?
      Verifier::ConstantExpression.new(first_token.value)
    elsif first_token == '('
      parse_parenthesized_expression
    else
      fail("Unrecognised token: #{first_token}")
    end

  end

  def parse_word_expression(first_word)
    case first_word.value
    when 'expect' then parse_expect_expression
    else
      Verifier::VariableExpression.new(first_word.value)
    end
  end

  def parse_expect_expression
    variables = parse_word_list
    expect(Token.word('where'))
    expr = parse_expression
    Verifier::ExpectExpression.new(variables, expr)
  end

  def parse_word_list
    words = []

    loop do
      words << parse_variable

      if @tokenizer.peek != ','
        break
      end
    end
    words
  end

  def parse_variable
    name = expect_type(:word)
    Verifier::VariableExpression.new(name.value)
  end

  def parse_parenthesized_expression
    inner = parse_expression
    expect(')')
    inner
  end

  def parse_binop_rhs(lhs, min_precedence)
    lookahead = @tokenizer.peek

    # I keep accidentally returning strings from the tokenizer
    # so we make sure tokens are being returned here.
    fail if !lookahead.nil? && !lookahead.is_a?(Token)

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
    token
  end

  def expect_type(type)
    token = @tokenizer.next
    fail if token.type != type
    token
  end
end
