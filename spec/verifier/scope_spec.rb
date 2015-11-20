require "spec_helper"

RSpec.describe Verifier::Scope do
  let(:statements) { [] }
  let(:variables) { {} }
  subject(:scope) { Verifier::Scope.new(statements, variables) }

  def mock_statement(str)
    class << str
      def static_evaluate(context)
        context
      end
    end
    str
  end

  describe "#to_s" do
    subject { scope.to_s }

    context "with no statements or variables" do
      it { is_expected.to eq "" }
    end

    context "with local variables" do
      let(:variables) { { "x" => 0, "y" => 1 } }
      it { is_expected.to eq "# x is 0, y is 1\n" }
    end

    context "with statements and no local variables" do
      let(:statements) { [mock_statement("first"), mock_statement("second")] }
      it { is_expected.to eq "first\nsecond\n" }
    end

    context "with statements and local variables" do
      let(:statements) { [mock_statement("one"), mock_statement("two")] }
      let(:variables) { { "z" => 0 } }
      it { is_expected.to eq <<-END }
# z is 0
one
# z is 0
two
# z is 0
      END
    end
  end
end
