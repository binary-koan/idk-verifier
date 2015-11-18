
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

  def ==(other)
    if self.nil? || other.nil?
      false
    else
      @type == other.type && @value == other.value
    end
  end
end

class Tokenizer
  def initialize(characters)
    @characters = characters
  end

  def next
    first_char = @characters.peek

    if first_char == '"'
      next_string
    elsif first_char =~ /[0-9]/
      next_integer
    else
      next_symbol
    end
  end

  private

  def next_string
    expect_character('"')
    value = take_until { |c| c=='"' }
    Token.string(value)
  end

  def next_integer
    value = take_until { |c| c !~ /[0-9]/ }.to_i
    Token.integer(value)
  end

  def next_symbol
    first_char = @characters.next

    case first_char
    # Tokens which may also assign (+=, *=, etc)
    when '+', '-',
         '*', '/',
         '='
      next_symbol_maybe_assign(first_char)
    # Tokens with a single character
    when '!'
      Token.symbol(first_char)
    else
      nil
    end
  end

  # The next symbol may have an equals suffix (+=, etc)
  def next_symbol_maybe_assign(first_char)
    if (@characters.peek rescue nil) == '='
      expect_character('=')
      Token.symbol("#{first_char}=")
    else
      Token.symbol(first_char)
    end
  end

  # Reads characters until the block returns true.
  # It does not eat the character that returned true
  def take_until(&block)
    chars = []

    loop do
      c = @characters.next

      if block.call(c)
        break
      else
        chars << c
      end
    end

    chars.join
  end

  def expect_character(character)
    fail if @characters.next != character
  end
end
