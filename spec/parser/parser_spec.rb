
require_relative '../../lib/parser/parser'

describe Parser do

  def parse_expression(msg)
    Parser.new(msg.chars.each).parse_expression
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

    it "parses logical AND" do
      expr = parse_expression("a&&true")
      expect(expr).to eq binop(:"&&", variable('a'), variable('true'))
    end

    it "parses logical OR" do
      expr = parse_expression("1 || false")
      expect(expr).to eq binop(:"||", constant(1), variable('false'))
    end
  end

  it "parses parenthesized expressions" do
    expect(parse_expression("(1234)")).to eq constant(1234)
  end

  # context "when parsing an expect expression" do
  #   it "sdfa" do
  #     expr = parse_expression("expect a where a > 0")
  #     expect(expr).to eq Verifier::ExpectExpression.new('a',
  #                           binop(:>, variable('a'), constant(0)))
  #   end
  # end
end
