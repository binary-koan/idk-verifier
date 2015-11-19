
require_relative '../../lib/parser/parser'

describe Parser do

  context "when parsing an add expression" do
    expression = Parser.new("123 + 321".chars.each).parse_expression
    puts "expr: #{expression}"

    it "does something" do

    end
  end
end
