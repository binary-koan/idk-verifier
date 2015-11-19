module Verifier
  class Context
    def initialize(statements, existing_variables={})
      @statements = statements
      @variables = existing_variables.dup
    end

    def verify
      variables = @variables.dup
      @statements.each { |stmt| stmt.static_evaluate(variables) }
    end

    def to_s
      variables = @variables.dup
      result = @statements.map do |stmt|
        known_info = known_variable_info(variables)
        stmt.static_evaluate(variables)
        "#{known_info}#{stmt}\n"
      end.join
      result += known_variable_info(variables)
      result
    end

    private

    def known_variable_info(variables)
      strings = variables.to_a.map { |name, value| "#{name} is #{value}" }.join(" && ")
      strings.empty? ? "" : "# #{strings}\n"
    end
  end
end
