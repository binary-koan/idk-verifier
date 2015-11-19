require "spec_helper"

# Dir.entries(File.expand_path("../scripts", __FILE__)).each do |script|
#   RSpec.describe "#{script} test script" do
#     let(:program) { Parser.parse_file(script) }
#
#     it "parses correctly" do
#       expect(program).to be_a Program
#     end
#
#     if script =~ /^expect_not/
#       it "throws an error when verifying" do
#         expect { program.verify }.to raise_error Verifier::AssertionError
#       end
#     else
#       it "verifies successfully" do
#         expect(program.verify).to be_truthy
#       end
#     end
#   end
# end
