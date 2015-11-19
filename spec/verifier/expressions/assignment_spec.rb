require "spec_helper"

RSpec.describe Verifier::AssignmentExpression do
  include_context "with expression builder"

  describe "#static_evaluate" do
    let(:context) { { "x" => Verifier::DefiniteRange.new(0, 100) } }

    context "when the variable does not exist in the context" do
      let(:expression) { assignment("y", constant(10)) }

      it "adds the variable to the context" do
        expression.static_evaluate(context)
        expect(context["y"]).to eq Verifier::DefiniteRange.new(10, 10)
        expect(context["x"]).to eq Verifier::DefiniteRange.new(0, 100)
      end
    end

    context "when the variable exists in the context" do
      let(:expression) { assignment("x", constant(10)) }

      it "changes the variable in the context" do
        expression.static_evaluate(context)
        expect(context["x"]).to eq Verifier::DefiniteRange.new(10, 10)
      end
    end
  end
end
