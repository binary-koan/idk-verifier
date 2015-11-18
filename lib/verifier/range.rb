module Verifier
  class Range
    include Enumerable

    attr_reader :upper
    attr_reader :lower

    def initialize(upper, lower)
      @upper = upper
      @lower = lower
    end

    def each
      (upper..lower).each { |i| yield i }
    end
  end
end
