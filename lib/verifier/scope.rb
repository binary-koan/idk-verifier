module Verifier
  class Scope
    def initialize(statements, base_variables={})
      @statements = statements
      @base_variables = base_variables.dup
    end

    def static_evaluate
      scope = ScopeContext.new(@base_variables)
      @statements.each { |stmt| stmt.static_evaluate(scope) }
    end

    def to_s
      scope = ScopeContext.new(@base_variables)

      result = @statements.map do |stmt|
        known_info = known_variable_info(scope)
        stmt.static_evaluate(scope)
        "#{known_info}#{stmt}\n"
      end.join

      result + known_variable_info(scope)
    end

    private

    def known_variable_info(scope)
      strings = scope.to_a.map { |name, value| "#{name} is #{value}" }.join(" && ")
      strings.empty? ? "" : "# #{strings}\n"
    end
  end

  class ScopeContext < Hash
    def initialize(variables={})
      super
      merge!(variables.dup)
    end

    def assign(values)
      merge!(values)
    end
  end
end
