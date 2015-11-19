
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

describe Tokenizer do

  def tokenizer(input)
    Tokenizer.new(input.chars.each)
  end

  def tokenize(input)
    tokenizer(input).next
  end

  def expect_token(input, output)
    token = tokenize(input)
    expect(token).to eq output
  end

  context "tokenizing a string" do

    it "reads an arbitrary string correctly" do
      expect_token('"abcd"', Token.string('abcd'))
    end

    it "reads an empty string correctly" do
      expect_token('""', Token.string(''))
    end
  end

  context "tokenizing an integer" do

    it "reads an arbitrary integer correctly" do
      expect_token('1234', Token.integer(1234))
    end
  end

  context "tokenizing a word" do
    it "reads the 'assert' word correctly" do
      expect_token('assert', Token.word('assert'))
    end
  end

  context "tokenizing a symbol" do

    it "reads an add symbol" do
      expect_token('+', Token.symbol('+'))
    end

    it "reads an addition assignment" do
      expect_token('+=', Token.symbol('+='))
    end

    it "does not accept a symbol which doesn't support assignment" do
      expect_token('!=', Token.symbol('!'))
    end
  end

  context "tokenizing a binary operator" do

    it "reads the things correctly" do
      tokenizer = tokenizer("123 + abc")
      expect(tokenizer.next).to eq 123
      expect(tokenizer.next).to eq '+'
    end
  end

  describe "#peek" do
    it "doesn't change the value of 'next'" do
      tokenizer = tokenizer("abc def")
      expect(tokenizer.next).to eq 'abc'
      expect(tokenizer.peek).to eq 'def'
    end
  end

  it "can tokenize more than one token in a row" do
    tokenizer = tokenizer("abc+def")
    expect(tokenizer.next).to eq "abc"
    expect(tokenizer.next).to eq "+"
    expect(tokenizer.next).to eq "def"
  end
end
