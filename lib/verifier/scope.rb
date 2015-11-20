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

    def initialize(statements)
      @statements = statements
    end

    def static_evaluate(context={})
      inner_context = context.dup
      @statements.each { |stmt| stmt.static_evaluate(inner_context) }
    end

    def to_s(context={})
      inner_context = context.dup

      result = @statements.map do |stmt|
        statement_to_string(stmt, inner_context)
      end.join

      result + known_variable_info(inner_context)
    end

    private

    def statement_to_string(expression, context)
      pre_info = known_variable_info(context)

      if expression.is_a?(Scope)
        str = expression.to_s(context)
      else
        expression.static_evaluate(context)
        str = expression.to_s
      end

      "#{pre_info}#{str}\n"
    end

    def known_variable_info(context)
      strings = context.to_a.map { |name, value| "#{name} is #{value}" }.join(", ")
      strings.gsub!(/\bInfinity\b/, "∞")
      strings.empty? ? "" : "# #{strings}\n"
    end
  end
end
