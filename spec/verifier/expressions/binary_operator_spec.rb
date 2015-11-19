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

  describe "#variable_constraints" do
    let(:context) { {} }

    context "with a simple expression of the form <variable> <operator> <constant>" do
      let(:constraints) { bin_op(operator, variable("x"), constant(100)).variable_constraints(context) }

      subject { constraints["x"].to_range }

      context "with the < operator" do
        let(:operator) { :< }
        it { is_expected.to eq value_range(upper: 99).to_range }
      end

      context "with the <= operator" do
        let(:operator) { :<= }
        it { is_expected.to eq value_range(upper: 100).to_range }
      end

      context "with the > operator" do
        let(:operator) { :> }
        it { is_expected.to eq value_range(lower: 101).to_range }
      end

      context "with the >= operator" do
        let(:operator) { :>= }
        it { is_expected.to eq value_range(lower: 100).to_range }
      end

      context "with the == operator" do
        let(:operator) { :== }
        it { is_expected.to eq value_range(lower: 100, upper: 100).to_range }
      end
    end

    context "with the && operator and two simple expressions" do
      let(:constraints) do
        bin_op(:"&&",
          bin_op(:<, variable("x"), constant(100)),
          bin_op(:>, variable("x"), constant(0))
        ).variable_constraints(context)
      end

      it "combines the constraints" do
        expect(constraints["x"].to_range).to eq value_range(lower: 1, upper: 99).to_range
      end
    end

    context "with the || operator and two simple expressions" do
      let(:constraints) do
        bin_op(:"||",
          bin_op(:>, variable("x"), constant(100)),
          bin_op(:<, variable("x"), constant(0))
        ).variable_constraints(context)
      end

      it "combines the constraints" do
        x_constraint = constraints["x"]
        expect(x_constraint).to be_a Verifier::UnionRange
        expect(x_constraint.ranges[0].to_range).to eq value_range(lower: 101).to_range
        expect(x_constraint.ranges[1].to_range).to eq value_range(upper: -1).to_range
      end
    end
  end
end
