require "spec_helper"

RSpec.describe Verifier::AssertExpression do
  include_context "with expression builder"

  describe "#static_evaluate" do
    let(:context) { { "x" => Verifier::DefiniteRange.new(0, 100) } }

    context "when asserting a variable is outside its range" do
      let(:expression) { assertion(bin_op(:>, variable("x"), constant(100))) }

      it "throws an assertion error" do
        expect { expression.static_evaluate(context) }.to raise_error Verifier::AssertionError
      end
    end

    context "when asserting a variable is inside its range" do
      let(:expression) { assertion(bin_op(:<, variable("x"), constant(200))) }

      it "succeeds and returns nil" do
        expect(expression.static_evaluate(context)).to be_nil
      end
    end
  end
end
