require "spec_helper"

RSpec.describe Verifier::BinaryOperatorExpression do
  describe "#static_evaluate" do
    let(:context) { { "x" => value_range(lower: 0, upper: 100) } }
    let(:expression) { bin_op(operator, first_operand, second_operand) }

    let(:first_operand) { constant(100) }
    let(:second_operand) { constant(50) }

    context "with the && operator and true operands" do
      let(:operator) { :"&&" }

      it "is truthy" do
        expect(expression.static_evaluate(context)).to be_truthy
      end
    end

    context "with the && operator and false operands" do
      let(:operator) { :"&&" }
      let(:first_operand) { bin_op(:<, variable("x"), constant(50)) }

      it "is falsy" do
        expect(expression.static_evaluate(context)).to be_falsy
      end
    end

    context "with the || operator and one false operand" do
      let(:operator) { :"||" }
      let(:first_operand) { bin_op(:>, variable("x"), constant(50)) }

      it "is truthy" do
        expect(expression.static_evaluate(context)).to be_truthy
      end
    end

    context "with the || operator and two false operands" do
      let(:operator) { :"||" }
      let(:first_operand) { bin_op(:>, variable("x"), constant(50)) }
      let(:second_operand) { first_operand }

      it "is falsy" do
        expect(expression.static_evaluate(context)).to be_falsy
      end
    end

    [:+, :-, :*, :/].each do |operator|
      context "using the arithmetic operator #{operator}" do
        let(:operator) { operator }
        let(:mock_range) { instance_double(Verifier::ValueRange) }
        let(:first_operand) { constant(mock_range) }

        it "passes the signal #{operator} to the result of the first operand" do
          expect(mock_range).to receive(operator).at_least(:once)
          expression.static_evaluate(context)
        end
      end
    end
  end
end
