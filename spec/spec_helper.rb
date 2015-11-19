require_relative "../lib/verifier/expression"
require_relative "../lib/verifier/range"
require_relative "../lib/verifier/scope"

RSpec.shared_context "with expression builder" do
  def expr(type, *args)
    name = type.to_s + "Expression"
    Verifier.const_get(name.to_sym).new(*args)
  end
end
