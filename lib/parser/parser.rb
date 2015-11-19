
require_relative 'token'
require_relative '../verifier/expression'
require_relative '../verifier/scope'

module Verifier

  # TODO: Properly set the precedences.

  # Unary operators which prefix things
  PREFIX_UNARY_OPERATORS = {
    '!' => { :precedence => 100, :sym => :! }, # Logical not
    '-' => { :precedence => 100, :sym => :- }, # Negation
    '+' => { :precedence => 100, :sym => :+ }, # No-operation
  }

  POSTFIX_UNARY_OPERATORS = {
    '!' => { :precedence => 10, :sym => :! }, # Factorial
  }

  BINARY_OPERATORS = {
    # Arithmetic
    '+' => { :precedence => 70, :sym => :+ }, # Addition
    '-' => { :precedence => 70, :sym => :- }, # Subtraction
    '*' => { :precedence => 80, :sym => :* }, # Multiplication
    '/' => { :precedence => 80, :sym => :/ }, # Division
    '^' => { :precedence => 10, :sym => :^ }, # Power

    '++' => { :precedence => 100, :sym => :"++" }, # Increment in place
    '--' => { :precedence => 100, :sym => :"--" }, # Decrement in place
    '+=' => { :precedence => 20,  :sym => :"+=" }, # Add in place
    '-=' => { :precedence => 20,  :sym => :"-=" }, # Subtract in place
    '*=' => { :precedence => 20,  :sym => :"*=" }, # Multiply in place
    '/=' => { :precedence => 20,  :sym => :"/=" }, # Divide in place

    # Comparisons
    '<'  => { :precedence => 60, :sym => :< }, # Less than
    '<=' => { :precedence => 60, :sym => :<= }, # Less than or equal to
    '>'  => { :precedence => 60, :sym => :> }, # Greater than
    '>=' => { :precedence => 60, :sym => :>= }, # Greater than or equal to
    '==' => { :precedence => 50, :sym => :== }, # Equals
    '!=' => { :precedence => 50, :sym => :!= }, # Not-equal-to

    # Logical
    '&&' => { :precedence => 40, :sym => :"&&" }, # And
    '||' => { :precedence => 30, :sym => :"||" }, # Or
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
    include Verifier

    def self.parse_file(filename)
      parser = Parser.new(File.read(filename).chars.each)
      expressions = []
      while (expression = parser.parse_expression)
        expressions << expression
      end

      Scope.new(expressions)
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
        ConstantExpression.new(first_token.value)
      elsif first_token.is_symbol?

        if first_token == '('
          parse_parenthesized_expression
        elsif PREFIX_UNARY_OPERATORS.include?(first_token.value)

          parse_prefix_unary_expression(first_token)
        end
      else
        fail("Unrecognised token: #{first_token}")
      end

    end

    def parse_word_expression(first_word)
      if @tokenizer.peek == '='
        return parse_assignment_expression(first_word)
      end

      case first_word.value
      when 'expect' then parse_expect_expression
      when 'assert' then parse_assertion
      else
        VariableExpression.new(first_word.value)
      end
    end

    def parse_prefix_unary_expression(sym_token)
      sym = PREFIX_UNARY_OPERATORS[sym_token.value][:sym]
      inner = parse_expression
      UnaryOperatorExpression.new(sym, inner)
    end

    def parse_expect_expression
      variables = parse_word_list
      expect(Token.word('where'))
      expr = parse_expression
      ExpectExpression.new(variables, expr)
    end

    def parse_assertion
      condition = parse_expression
      AssertExpression.new(condition)
    end

    def parse_assignment_expression(variable)
      assert_token(Token.symbol('='))
      expr = parse_expression
      AssignmentExpression.new(variable.value, expr)
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
      VariableExpression.new(name.value)
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
        lhs = BinaryOperatorExpression.new(BINARY_OPERATORS[op.value][:sym], lhs, rhs)
      end
      lhs
    end

    def expect(value)
      token = @tokenizer.next
      fail if token != value
      token
    end

    # TODO: Use 'assert_token' for internal assertions and use
    # 'expect' for errors which should be shown to the user.
    # assert_token should fail but expect should raise
    def assert_token(value)
      expect(value)
    end

    def expect_type(type)
      token = @tokenizer.next
      fail if token.type != type
      token
    end
  end
end
