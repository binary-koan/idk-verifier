require_relative "expression"

module Verifier
  class Scope
    def self.intersect_constraints(first_values, second_values)
      first_values.merge(second_values) do |name, value1, value2|
        if value1 && value2
          value1 & value2
        else
          value1 || value2
        end
      end
    end

    def self.unite_constraints(first_values, second_values)
      first_values.merge(second_values) do |name, value1, value2|
        if value1 && value2
          UnionRange.new(value1, value2)
        else
          value1 || value2
        end
      end
    end

    def initialize(statements, base_variables={})
      @statements = statements
      @base_variables = base_variables.dup
    end

    def static_evaluate
      scope = @base_variables.dup
      @statements.each { |stmt| stmt.static_evaluate(scope) }
    end

    def to_s
      scope = @base_variables.dup

      result = @statements.map do |stmt|
        known_info = known_variable_info(scope)
        stmt.static_evaluate(scope)
        "#{known_info}#{stmt}\n"
      end.join

      result + known_variable_info(scope)
    end

    private

    def known_variable_info(scope)
      strings = scope.to_a.map { |name, value| "#{name} is #{value}" }.join(", ")
      strings.gsub!(/\bInfinity\b/, "∞")
      strings.empty? ? "" : "# #{strings}\n"
    end
  end
end
