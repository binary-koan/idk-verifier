
class Characters

  def initialize(characters)
    @characters = characters
    @buffer = []
  end

  def next
    if !@buffer.empty?
      return @buffer.pop
    end

    @characters.next rescue nil
  end

  def eat_whitespace
    c = self.next
    while c && c.strip.empty?
      c = self.next
    end
    feed(c) if c
  end

  def feed(character)
    @buffer.push(character)
  end

  def peek
    peeked = self.next
    feed(peeked)
    peeked
  end

  def eat
    self.next
  end
end

class Token

  attr_reader :type, :value

  def self.string(value)
    Token.new(:string, value)
  end

  def self.integer(value)
    Token.new(:integer, value)
  end

  def self.word(value)
    Token.new(:word, value)
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

  def is_word?
    @type == :word
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
    if other.is_a?(Token)
      if self.nil? || other.nil?
        false
      else
        @type == other.type && @value == other.value
      end
    else
      @value == other
    end
  end
end

class Tokenizer
  def initialize(characters)
    @characters = Characters.new(characters)
  end

  def next
    if @peek_buf
      token = @peek_buf
      @peek_buf = nil
      return token
    end

    @characters.eat_whitespace
    first_char = @characters.peek

    if first_char == '"'
      next_string
    elsif first_char =~ /[0-9]/
      next_integer
    elsif first_char =~ /[[:alpha:]]/
      next_word
    else
      next_symbol
    end
  end

  def peek
    token = self.next
    @peek_buf = token
    token
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

  def next_word
    value = take_until { |c| c !~ /([[:alpha:]]|[[:digit:]]|_)/ }
    Token.word(value)
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
    end
  end

  # The next symbol may have an equals suffix (+=, etc)
  def next_symbol_maybe_assign(first_char)
    Token.symbol(if (@characters.peek rescue nil) == '='
      expect_character('=')
      "#{first_char}="
    else
      first_char
    end)
  end

  # Reads characters until the block returns true.
  # It does not eat the character that returned true
  def take_until(&block)
    chars = []

    loop do
      c = @characters.next

      if block.call(c)
        @characters.feed(c)
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
