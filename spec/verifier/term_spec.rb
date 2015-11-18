require_relative "../../lib/verifier/term"

RSpec.describe Verifier::ConstantTerm do
  describe "#value" do
    it "returns the value passed into the constructor" do
      constant = Verifier::ConstantTerm.new(3)
      expect(constant.value).to eq 3
    end
  end

  describe "#combine" do
    it "adds the values of the constants together" do
      constant1 = Verifier::ConstantTerm.new(4)
      constant2 = Verifier::ConstantTerm.new(2)
      expect(constant1.combine(constant2).value).to eq 6
    end
  end
end
