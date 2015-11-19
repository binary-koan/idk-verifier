#! /usr/bin/ruby


require_relative 'parser/token'
require_relative 'parser/parser'

FILENAME = ARGV[0]

puts "Opening '#{FILENAME}'"

scope = Parser.parse_file(FILENAME)

if scope.static_evaluate
  puts "'#{FILENAME}' passed verification"
else
  puts "'#{FILENAME}' failed verification"
end
