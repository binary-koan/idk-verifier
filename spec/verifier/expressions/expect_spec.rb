require "spec_helper"

RSpec.describe Verifier::ExpectExpression do
  describe "#static_evaluate" do
    context "with a simple constraint on one variable" do
      let(:expression) do
        expectation(["x"], bin_op(:"&&",
          bin_op(:>, variable("x"), constant(0)),
          bin_op(:<, variable("x"), constant(100))
        ))
      end

      it "sets up a variable range in locals" do
        locals = Verifier::ScopeContext.new
        expression.static_evaluate(locals)
        expect(locals["x"]).to eq value_range(lower: 1, upper: 99)
      end
    end
  end
end
