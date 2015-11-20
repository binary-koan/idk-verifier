require "spec_helper"

RSpec.describe Verifier::VariableExpression do
  describe "#static_evaluate" do
    let(:expression) { variable("x") }

    context "when the variable does not exist in the current context" do
      it "returns a default value range" do
        expect(expression.static_evaluate({})).to eq value_range
      end

      it "sets the variable in the context" do
        context = {}
        expression.static_evaluate(context)
        expect(context["x"]).to eq value_range
      end
    end

    it "returns the value of a variable in the context" do
      result = expression.static_evaluate({ "x" => value_range(upper: 1, lower: 1) })
      expect(result.to_range).to eq 1..1
    end
  end
end
