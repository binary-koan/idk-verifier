module Verifier
  class Variable
    def initialize(name, value, known_properties)
      @name = name
      @value = value
      @known_properties = known_properties
    end

    # eg. x = 3 # => locals[:x].with_value(Constant.new(3))
    def with_value(value)
      Variable.new(@name, value, [])
    end

    # eg. if x > y # => locals[:x].with_property(...)
    def with_property(property)
      Variable.new(@name, @value, @known_properties + [property])
    end

    def to_s
      str = "#{@name} == #{@value.to_s}"
      str += "&& #{@known_properties.join(" && ")}" unless @known_properties.empty?
    end
  end
end
