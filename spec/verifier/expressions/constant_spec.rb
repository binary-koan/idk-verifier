require "spec_helper"

RSpec.describe Verifier::ConstantExpression do
  include_context "with expression builder"

  describe "#static_evaluate" do
    let(:expression) { expr(:Constant, 100) }

    it "returns a definite range" do
      expect(expression.static_evaluate({})).to be_a(Verifier::DefiniteRange)
    end

    it "has identical upper and lower bounds" do
      range = expression.static_evaluate({})
      expect(range.upper).to eq range.lower
      expect(range.upper).to eq 100
    end
  end
end
