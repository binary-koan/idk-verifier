require_relative "../scope"

module Verifier

  # A single branch in an if-elsif-else block.
  #
  # This consists of a condition and a body.
  # Else blocks have no condition (nil).
  class IfBranch

    attr_reader :condition, :body

    def self.if(condition, body)
      IfBranch.new(condition, body)
    end

    def self.else(body)
      IfBranch.new(nil, body)
    end

    def initialize(condition, body)
      @condition = condition
      @body = body
    end

    def else?
      # Else blocks have no condition
      @condition == nil
    end

    def ==(other)
      if other.is_a?(IfBranch)
        @condition == other.condition && @body == other.body
      else
        false
      end
    end
  end

  class IfExpression < Scope
    include Expression

    attr_reader :branches

    def initialize(*branches)
      @branches = branches

      # TODO: Make sure there is only one else
      # (unconditional) branch.
    end

    def static_evaluate(context)
      fail("Only if {} else {} is supported") unless @branches.size == 2 && @branches[1].else?

      expression = branches.first.condition
      true_expressions = branches[0].body
      false_expressions = branches[1].body

      constraints = expression.variable_constraints(context)
      inverse_constraints = {}
      constraints.each { |name, value| inverse_constraints[name] = value.inverse }

      false_context = context.merge(inverse_constraints)
      false_expressions.each { |expr| expr.static_evaluate(false_context) }

      #TODO: What if it can never happen?
      if expression.can_happen?(context)
        true_context = context.merge(constraints)
        true_expressions.each { |expr| expr.static_evaluate(true_context) }

        context.merge!(Scope.unite_constraints(true_context, false_context))
      else
        context.merge!(false_context)
      end
    end

    def ==(other)
      if other.is_a?(IfExpression)
        @branches == other.branches
      else
        false
      end
    end

    def to_s(context={})
      # Argh! The duplication!
      expression = branches.first.condition
      true_expressions = branches[0].body
      false_expressions = branches[1].body

      constraints = expression.variable_constraints(context)
      inverse_constraints = {}
      constraints.each { |name, value| inverse_constraints[name] = value.inverse }

      result = "if #{@branches[0].condition} {\n"

      if expression.can_happen?(context)
        true_context = context.merge(constraints)
        true_expressions.each { |expr| result += statement_to_string(expr, true_context) }
        result += known_variable_info(true_context)
      else
        result += "# can never happen!\n"
      end

      result += "}\nelse {\n"

      false_context = context.merge(inverse_constraints)
      false_expressions.each { |expr| result += statement_to_string(expr, false_context) }

      if expression.can_happen?(context)
        context.merge!(Scope.unite_constraints(true_context, false_context))
      else
        context.merge!(false_context)
      end

      result + known_variable_info(false_context) + "}"
    end
  end
end
