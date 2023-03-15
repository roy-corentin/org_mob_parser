require "./regex"

module OrgMob
  alias Lexed = NamedTuple("type": Symbol, "content": String)

  class Lexer
    alias LexerFunctionType = Proc(String, NamedTuple("type": Symbol, "content": String))

    def self.call(data : Array(String)) : Array(Lexed)
      return data.each_with_object([] of Lexed, &self.call_appropriate_lexer)
    end

    def self.format(type : Symbol, content : String) : Lexed
      {type: type, content: content}
    end

    private def self.call_appropriate_lexer
      ->(line : String, array : Array(Lexed)) { REGEXS.each { |regex| return array << self.format(regex[:type], line) if line.match(regex[:regex]) } }
    end
  end
end
