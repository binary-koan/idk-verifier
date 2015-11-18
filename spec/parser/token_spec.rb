
require_relative '../../lib/parser/token'

describe Token do

  context "is a string" do
    let(:token) { Token.string("hello world") }

    it "is recognized as a string" do
      expect(token.is_string?).to eq true
    end

    it "is printed in double quotes" do
      expect(token.to_s).to match(/"*"/)
    end
  end

  context "is an integer" do
    let(:token) { Token.integer(1234) }

    it "is recognized as an integer" do
      expect(token.is_integer?).to eq true
    end

    it "is printed as a plain number" do
      expect(token.to_s).to eq "1234"
    end
  end

  context "is a symbol" do
    let(:token) { Token.symbol('<') }

    it "is recognized as a symbol" do
      expect(token.is_symbol?).to eq true
    end

    it "is printed as a plain symbol" do
      expect(token.to_s).to eq '<'
    end
  end
end
