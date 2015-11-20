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

  class IfExpression
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

      true_context = context.merge(constraints)
      true_expressions.each { |expr| expr.static_evaluate(true_context) }
      false_context = context.merge(inverse_constraints)
      false_expressions.each { |expr| expr.static_evaluate(false_context) }

      context.merge!(Scope.unite_constraints(true_context, false_context))
    end

    def ==(other)
      if other.is_a?(IfExpression)
        @branches == other.branches
      else
        false
      end
    end
  end
end
