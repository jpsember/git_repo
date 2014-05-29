class GitParser

  def initialize(content)
    @content = content
    @cursor = 0
  end

  def parse_chars(length = 1)
    cursor2 = @cursor + length
    raise Exception,"no more characters" if cursor2 > @content.length
    substring = @content[@cursor...cursor2]
    @cursor = cursor2
    substring
  end

  def parse(expected = ' ')
    substring = parse_chars(expected.length)
    raise Exception,"unexpected characters" if substring != expected
  end

  def peek(expected = nil)
    c = nil
    if expected
      if @cursor + expected.length <= @content.length
        if @content[@cursor,expected.length] == expected
          c = expected
        end
      end
    else
      if @cursor < @content.length
        c = @content[@cursor]
      end
    end
    c
  end

  def read_if(expected)
    res = peek(expected)
    @cursor += expected.length if res
    res
  end

  def parse_path()
    x = ''
    if (peek() == '"')
      parse('"')
      while peek() != '"'
        y = parse_chars()
        if y == "\""
          y = parse_chars()
        end
        x << y
      end
      parse('"')
    else
      while true
        y = peek()
        break if !y || y == ' '
        x << y
        parse_chars
      end
    end
    x
  end

end
