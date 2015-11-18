require "spec_helper"

RSpec.describe Verifier::LogicalExpression do
  def expression(value)
    instance_double(Verifier::VerifiableExpression, valid?: value)
  end

  context "when operator = :and" do
    it "fails with a false operand" do
      expr = Verifier::LogicalExpression.new(:and, expression(false), expression(true))
      expect(expr).not_to be_valid
    end

    it "succeeds when both operands are true" do
      expr = Verifier::LogicalExpression.new(:and, expression(true), expression(true))
      expect(expr).to be_valid
    end
  end

  context "when operator = :or" do
    it "fails when both operands are false" do
      expr = Verifier::LogicalExpression.new(:or, expression(false), expression(false))
      expect(expr).not_to be_valid
    end

    it "succeeds with a true operand" do
      expr = Verifier::LogicalExpression.new(:or, expression(false), expression(true))
      expect(expr).to be_valid
    end
  end
end

RSpec.describe Verifier::SimpleExpression do
  describe "#constant_value" do
  end
end
