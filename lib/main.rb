#! /usr/bin/ruby


require_relative 'parser/token'
require_relative 'parser/parser'

FILENAME = ARGV[0]

puts "Opening '#{FILENAME}'"

code = File.read(FILENAME)
parser = Parser.new(code)

loop do
  expr = parser.parse_expression
  puts "Expression: #{expr}"
end
