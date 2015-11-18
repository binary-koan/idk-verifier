module Verifier
  class Scope
    def initialize(statements, locals=[])
      @statements = statements
      @locals = locals
    end

    def to_s
      locals = @locals.dup
      result = @statements.map do |stmt|
        known_truths = "# #{locals.join(" && ")}\n" unless locals.empty?
        locals = stmt.static_evaluate(locals)
        "#{known_truths}#{stmt}\n"
      end.join
      result += "# #{locals.join(" && ")}\n" unless locals.empty?
      result
    end
  end
end
