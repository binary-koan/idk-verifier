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

  it "creates a string from the program" do
    scope = Verifier::Scope.new(expressions)
    expect(scope.to_s).to eq <<-END
expect x where x >= 0 && x <= 100
# x is 0..100
y = x * 2 + 100
# x is 0..100, y is 100..300
assert x >= 0 && x <= 100
# x is 0..100, y is 100..300
assert x > -1 && x < 101
# x is 0..100, y is 100..300
assert y >= 100 && y <= 300
# x is 0..100, y is 100..300
    END
  end
end

RSpec.describe "Basic failing condition" do
  let(:expressions) do
    [
      expectation(["x"], bin_op(:"&&",
        bin_op(:>=, variable("x"), constant(0)),
        bin_op(:<=, variable("x"), constant(100))
      )),
      assertion(bin_op(:>, variable("x"), constant(100)))
    ]
  end

  it "raises an error when verifying the conditions" do
    context = {}
    expect do
      expressions.each { |e| e.static_evaluate(context) }
    end.to raise_error Verifier::AssertionError
  end
end
