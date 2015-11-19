RSpec.describe "Basic successful conditions" do
  let(:expressions) do
    [
      expectation(["x"], bin_op(:"&&",
        bin_op(:>=, variable("x"), constant(0)),
        bin_op(:<=, variable("x"), constant(100))
      )),
      assignment("y", bin_op(:+,
        bin_op(:*, variable("x"), constant(2)), constant(100)
      )),
      assertion(bin_op(:"&&",
        bin_op(:>=, variable("x"), constant(0)),
        bin_op(:<=, variable("x"), constant(100))
      )),
      assertion(bin_op(:"&&",
        bin_op(:>, variable("x"), constant(-1)),
        bin_op(:<, variable("x"), constant(101))
      )),
      assertion(bin_op(:"&&",
        bin_op(:>=, variable("y"), constant(100)),
        bin_op(:<=, variable("y"), constant(300))
      ))
    ]
  end

  it "verifies the conditions" do
    context = {}
    expressions.each { |e| e.static_evaluate(context) }

    expect(context["x"]).to eq value_range(lower: 0, upper: 100)
    expect(context["y"]).to eq value_range(lower: 100, upper: 300)
  end
end
