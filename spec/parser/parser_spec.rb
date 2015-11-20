
require_relative '../../lib/parser/parser'

describe Verifier::Parser do

  def parse_expression(msg)
    Verifier::Parser.new(msg.chars.each).parse_expression
  end

  def unary(sym, inner)
    Verifier::UnaryOperatorExpression.new(sym, inner)
  end

  def binop(sym, lhs, rhs)
    Verifier::BinaryOperatorExpression.new(sym, lhs, rhs)
  end

  def variable(name)
    Verifier::VariableExpression.new(name)
  end

  def constant(value)
    Verifier::ConstantExpression.new(value)
  end

  def assignment(name, value)
    Verifier::AssignmentExpression.new(name, value)
  end

  def if_expr(cond, body)
    branches = [ Verifier::IfBranch.if(cond, body) ]
    Verifier::IfExpression.new(branches)
  end

  def if_elseif_else_expr(cond1, body1,
                          cond2, body2,
                          else_body)
    branches = [ Verifier::IfBranch.if(cond1, body1),
                 Verifier::IfBranch.if(cond2, body2),
                 Verifier::IfBranch.else(else_body) ]
    Verifier::IfExpression.new(branches)
  end

  def if_else_expr(cond, body, else_body)
    branches = [ Verifier::IfBranch.if(cond, body),
                 Verifier::IfBranch.else(else_body) ]
    Verifier::IfExpression.new(branches)
  end

  def while_expr(cond, body)
    Verifier::WhileExpression.new(cond, body)
  end

  context "binary operators" do

    it "parses addition" do
      expr = parse_expression("123+abc")
      expect(expr).to eq binop(:+, constant(123), variable('abc'))
    end

    it "parses subtraction" do
      expr = parse_expression("abc - def")
      expect(expr).to eq binop(:-, variable('abc'), variable('def'))
    end

    it "parses multiplication" do
      expr = parse_expression("5 * 5")
      expect(expr).to eq binop(:*, constant(5), constant(5))
    end

    it "parses division" do
      expr = parse_expression("1/1")
      expect(expr).to eq binop(:/, constant(1), constant(1))
    end

    it "parses exponentials" do
      expr = parse_expression("5^2")
      expect(expr).to eq binop(:^, constant(5), constant(2))
    end

    context "comparisons" do

      it "parses logical AND" do
        expr = parse_expression("a&&true")
        expect(expr).to eq binop(:"&&", variable('a'), variable('true'))
      end

      it "parses logical OR" do
        expr = parse_expression("1 || false")
        expect(expr).to eq binop(:"||", constant(1), variable('false'))
      end

      it "knows that multiplication has a higher precedence than addition" do
        expr = parse_expression("1 + 2 * 2")
        inner = binop(:*, constant(2), constant(2))
        expect(expr).to eq binop(:+, constant(1), inner)
      end

      it "knows that AND has a higher precedence than OR" do
        expr = parse_expression("A && B || C")
        inner = binop(:"&&", variable('A'), variable('B'))
        expect(expr).to eq binop(:"||", inner, variable('C'))
      end

      it "parses equality" do
        expr = parse_expression("123 == 321")
        expect(expr).to eq binop(:==, constant(123), constant(321))
      end

      it "parses inequality" do
        expr = parse_expression("aaa != 222")
        expect(expr).to eq binop(:!=, variable('aaa'), constant(222))
      end
    end
  end

  context "prefix unary operators" do
    it "parses arithmetic negation" do
      expr = parse_expression('-abc')
      expect(expr).to eq unary(:-, variable('abc'))
    end

    it "parses boolean negation" do
      expr = parse_expression('!123')
      expect(expr).to eq unary(:!, constant(123))
    end
  end

  it "parses parenthesized expressions" do
    expect(parse_expression("(1234)")).to eq constant(1234)
  end

  it "parses an assignment expression" do
    expr = parse_expression("abcd = 1234")
    expect(expr).to eq assignment(variable('abcd'), constant(1234))
  end

  it "parses an expect expression" do
    expr = parse_expression("expect a where a > 0")
    expect(expr).to eq Verifier::ExpectExpression.new('a',
                          binop(:>, variable('a'), constant(0)))
  end

  it "parses an expect expression with multiple predicates" do
    expr = parse_expression("expect a where a > 0, a < 100")
    expect(expr).to eq Verifier::ExpectExpression.new('a',
                          binop(:"&&",
                              binop(:>, variable('a'), constant(0)),
                              binop(:<, variable('a'), constant(100))))
  end

  it "parses an assertion" do
    expr = parse_expression("assert a >= 0")
    expect(expr).to eq Verifier::AssertExpression.new(
                          binop(:>=, variable('a'), constant(0)))
  end

  context "if blocks" do
    it "parses a plain if block" do
      expr = parse_expression("if abc { }")
      expect(expr).to eq if_expr(variable('abc'), [])
    end

    it "parses an if-else block" do
      expr = parse_expression("if abc { 123 } else { 321 }")
      expect(expr).to eq if_else_expr(
              variable('abc'), [ constant(123) ],
              [ constant(321) ])
    end

    it "parses an if-elseif-else block" do
      expr = parse_expression("if a { 1 } elseif b { 2 } else { 3 }")
      expect(expr).to eq if_elseif_else_expr(
            variable('a'), [ constant(1) ],
            variable('b'), [ constant(2) ],
            [ constant(3) ])
    end
  end

  context "while blocks" do
    it "parses a trivial while block" do
      expr = parse_expression("while abc { 1 }")
      expect(expr).to eq while_expr(variable('abc'), [ constant(1) ])
    end
  end
end
