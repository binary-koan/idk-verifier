module Verifier
  class Scope
    def initialize(statements, locals=[])
      @statements = statements
      @locals = locals
    end

    def to_s
      result = ""
      locals = @locals.dup
      @statements.each do |stmt|
        result += "# #{locals.join(" && ")}\n" unless locals.empty?
        result += stmt + "\n"
        locals = stmt.static_evaluate(locals)
      end
      result += "# #{locals.join(" && ")}\n" unless locals.empty?
      result
    end
  end
end
