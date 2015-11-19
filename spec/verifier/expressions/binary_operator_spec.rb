require "spec_helper"

RSpec.describe Verifier::BinaryOperatorExpression do
  include_context "with expression builder"

  describe "#static_evaluate" do
    let(:context) { { "x" => Verifier::DefiniteRange.new(0, 100) } }
    let(:expression) { expr(:BinaryOperator, operator, first_operand, second_operand) }

    let(:first_operand) { expr(:Constant, 100) }
    let(:second_operand) { expr(:Constant, 50) }

    context "with the && operator and true operands" do
      let(:operator) { :"&&" }

      it "is truthy" do
        expect(expression.static_evaluate(context)).to be_truthy
      end
    end

    context "with the && operator and false operands" do
      let(:operator) { :"&&" }
      let(:first_operand) { expr(:BinaryOperator, :<, expr(:Variable, "x"), expr(:Constant, 50)) }

      it "is falsy" do
        expect(expression.static_evaluate(context)).to be_falsy
      end
    end

    [:+, :-, :*, :/].each do |operator|
      context "using the arithmetic operator #{operator}" do
        let(:operator) { operator }
        let(:mock_range) { instance_double(Verifier::DefiniteRange) }
        let(:first_operand) { expr(:Constant, mock_range) }

        it "passes the signal #{operator} to the result of the first operand" do
          expect(mock_range).to receive(operator)
          expression.static_evaluate(context)
        end
      end
    end
  end
end
