module Verifier

  class WhileExpression

    attr_reader :condition, :body

    def new(condition, body)
      @condition = condition
      @body = body
    end

    def ==(other)
      if other.is_a?(WhileExpression)
        @condition == other.condition && @body == other.body
      else
        false
      end
    end
  end
end
