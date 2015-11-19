require "spec_helper"

RSpec.describe Verifier::VariableExpression do
  include_context "with expression builder"

  describe "#static_evaluate" do
    let(:expression) { variable("x") }

    it "fails if the variable is not in the context" do
      expect { expression.static_evaluate({}) }.to raise_error Verifier::UndefinedVariableError
    end

    it "returns the value of a variable in the context" do
      result = expression.static_evaluate({ "x" => 1 })
      expect(result).to eq 1
    end
  end
end
