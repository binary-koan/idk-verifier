module Verifier
  class VerifiableExpression
    def initialize(operator, lhs, rhs)
      @operator = operator
      @lhs = lhs
      @rhs = rhs
    end

    def valid?
      true
    end
  end

  # Expression with a logical condition eg. x == 0 && y == 1
  class LogicalExpression < VerifiableExpression
    def valid?
      case @operator
      when :and
        @lhs.valid? && @rhs.valid?
      when :or
        @lhs.valid? || @rhs.valid?
      end
    end
  end

  # Non-logical expression eg. x == y or x + y > 0
  class ComparisonExpression < VerifiableExpression
    def valid?
      @lhs.move_variables_to(@rhs)
      return false unless @rhs.constant?

      case @operator
      when :equal
        @lhs.equal?(@rhs.constant_value)
      when :greater_than
        @lhs.gt?(@rhs.constant_value)
      when :less_then
        @lhs.lt?(@rhs.constant_value)
      end
    end
  end

  class SimpleExpression
    def initialize(terms)
      @terms = terms
    end

    def move_variables_to(other)
      vars, @terms = @terms.partition { |term| term.is_a?(VariableTerm) }
      other.add_terms(vars)
    end

    def add_terms(*terms)
      @terms += terms
    end

    def constant_value
      @terms.select { |term| term.is_a?(ConstantTerm) }.inject(0) do |sum, term|
        sum + term.value
      end
    end

    def equal?(value)
      vars, value = simplify(value)
    end

    def gt?(value)
      vars, value = simplify(value)
    end

    def lt?(value)
      vars, value = simplify(value)
    end

    private

    def simplify(constant_value)
      vars = {}
      constant = Constant.new(constant_value)
      @terms.each do |term|
        if term.is_a?(Variable)
          vars[term.name] = combine_vars(vars[term.name], term)
        elsif term.is_a?(Constant)
          constant = constant.combine(term)
        end
      end
      [vars, constant]
    end

    def combine_vars(first, second)
      if first && second
        first.combine(second)
      else
        first || second
      end
    end
  end
end
