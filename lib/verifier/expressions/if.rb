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

    def is_else
      # Else blocks have no condition
      @condition == nil
    end
  end

  class IfExpression
    include Expression

    attr_reader :branches

    def initialize(branches)
      @branches = branches

      # TODO: Make sure there is only one else
      # (unconditional) branch.
    end
  end
end
