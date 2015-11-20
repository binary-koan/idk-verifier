RSpec.describe Verifier::IfExpression do
  context "with variables bound to constants" do
    let(:context) { { "x" => value_range(lower: 5, upper: 5) } }

    let(:expression) do
      if_condition(
        bin_op(:==, variable("x"), constant(5)),
        [assignment("x", constant(6))],
        [assignment("x", constant(7))]
      )
    end

    it "unites the value ranges of x" do
      expression.static_evaluate(context)
      expect(context["x"]).to be_a Verifier::UnionRange
      first_range, second_range = context["x"].ranges
      expect(first_range.to_range).to eq 6..6
      expect(second_range.to_range).to eq 7..7
    end
  end

  context "with union-range variables" do
    let(:context) do
      { "x" => union_range(value_range(upper: 0), value_range(lower: 100)) }
    end

    let(:expression) do
      if_condition(
        bin_op(:>=, variable("x"), constant(200)),
        [
          assertion(bin_op(:>=, variable("x"), constant(200))),
          assignment("x", constant(2))
        ], []
      )
    end

    it "unites the value ranges of x" do
      expression.static_evaluate(context)
      expect(context["x"]).to be_a Verifier::UnionRange

      first, second = context["x"].ranges
      expect(first.to_range).to eq 2..2
      expect(second.to_range).to eq Verifier::NEGATIVE_INFINITY..200
    end
  end
end
