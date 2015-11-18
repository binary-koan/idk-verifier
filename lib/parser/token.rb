
class Token

  attr_reader :type, :value

  def self.string(value)
    Token.new(:string, value)
  end

  def self.integer(value)
    Token.new(:integer, value)
  end

  def self.symbol(value)
    Token.new(:symbol, value)
  end

  def initialize(type, value)
    @type = type
    @value = value
  end

  def is_string?
    @type == :string
  end

  def is_integer?
    @type == :integer
  end

  def is_symbol?
    @type == :symbol
  end

  def to_s
    case @type
    when :string
      "\"#{@value}\""
    else
      @value.to_s
    end
  end
end

class Tokenizer
  def initialize(characters)
    @characters = characters
  end

  def next
    first_char = @characters.next

    if first_char == '"'
      next_string
    end
  end

  private

  def next_string
    value = @characters.each.take_while { |a| a != '"' }

    @characters.next # eat end quote

    Token.string(value)
  end
end
