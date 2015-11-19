require "spec_helper"

RSpec.describe Verifier::ConstantExpression do
  describe "#static_evaluate" do
    let(:expression) { constant(100) }

    it "returns a definite range" do
      expect(expression.static_evaluate({})).to be_a(Verifier::ValueRange)
    end

    it "has identical upper and lower bounds" do
      range = expression.static_evaluate({})
      expect(range.upper).to eq range.lower
      expect(range.upper).to eq 100
    end
  end
end
