require "spec_helper"

Dir.entries(File.expand_path("../tests", __FILE__)).each do |file|
  next if file =~ /^..?$/
  require_relative "tests/#{file}"
end

SCRIPTS_DIR = File.expand_path("../scripts", __FILE__)
Dir.entries(SCRIPTS_DIR).each do |script|
  next if script =~ /^..?$/
  RSpec.describe "#{script} test script" do
    let(:program) { Parser.parse_file("#{SCRIPTS_DIR}/#{script}") }

    it "parses correctly" do
      expect(program).to be_a Verifier::Scope
    end

    if script =~ /fail/
      it "throws an error when verifying" do
        expect { program.static_evaluate }.to raise_error Verifier::AssertionError
      end
    else
      it "verifies successfully" do
        expect(program.static_evaluate).to be_truthy
      end
    end
  end
end
