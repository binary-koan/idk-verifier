require "spec_helper"

RSpec.describe Verifier::ExpectExpression do
  include_context "with expression builder"

  describe "#static_evaluate" do
    context "with a simple constraint on one variable" do
      let(:expression) do
        expr(:Expect, ["x"], expr(:BinaryOperator, :"&&",
          expr(:BinaryOperator, :>, expr(:Variable, "x"), expr(:Constant, 0)),
          expr(:BinaryOperator, :<, expr(:Variable, "x"), expr(:Constant, 100))
        ))
      end

      it "sets up a variable range in locals" do
        locals = {}
        expression.static_evaluate(locals)
        expect(locals["x"]).to eq Verifier::DefiniteRange.new(1, 99)
      end
    end
  end
end
