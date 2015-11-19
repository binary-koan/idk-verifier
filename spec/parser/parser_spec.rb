
require_relative '../../lib/parser/parser'

describe Parser do

  def parse_expression(msg)
    Parser.new(msg.chars.each).parse_expression
  end

  def binop(sym, lhs, rhs)
    Verifier::BinaryOperatorExpression.new(sym, lhs, rhs)
  end

  context "when parsing an add expression" do

    it "parses addition" do
      expr = parse_expression("123+abc")
      expect(expr).to eq binop(:+, 123, 'abc')
    end
  end

  it "parses parenthesized expressions" do
    expect(parse_expression("(1234)")).to eq 1234
  end

  # context "when parsing an expect expression" do
  #   it "sdfa" do
  #     expr = parse_expression("expect a where a > 0")
  #     expect(expr).to eq Verifier::ExpectExpression.new('a', 'a > 0')
  #   end
  # end
end
