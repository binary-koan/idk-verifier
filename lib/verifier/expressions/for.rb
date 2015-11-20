module Verifier

  # A C style for-loop.
  #
  # for (begin; end; step) {
  #     body
  # }
  class ForExpression

    attr_reader :begin, :end, :step, :body

    def initialize(begin_expr, end_cond,
                   step, body)
      @begin = begin_expr
      @end = end_cond
      @step = step
      @body = body
    end

    def ==(other)
      if other.is_a?(ForExpression)
        @begin == other.begin &&
        @end == other.end &&
        @step == other.step
        @body == other.body
      else
        false
      end
    end

  end
end
