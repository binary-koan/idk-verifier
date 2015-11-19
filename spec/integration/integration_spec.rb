require "spec_helper"

Dir.entries(File.expand_path("../tests", __FILE__)).each do |file|
  next if file =~ /^..?$/
  require_relative "tests/#{file}"
end

# Dir.entries(File.expand_path("../scripts", __FILE__)).each do |script|
#   next if script =~ /^..?$/
#   RSpec.describe "#{script} test script" do
#     let(:program) { Parser.parse_file(script) }
#
#     it "parses correctly" do
#       expect(program).to be_a Scope
#     end
#
#     if script =~ /^expect_not/
#       it "throws an error when verifying" do
#         expect { program.static_evaluate }.to raise_error Verifier::AssertionError
#       end
#     else
#       it "verifies successfully" do
#         expect(program.static_evaluate).to be_truthy
#       end
#     end
#   end
# end
