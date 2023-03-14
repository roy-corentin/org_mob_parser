require "./regex"

module OrgMob
  alias Lexed = NamedTuple("type": Symbol, "content": String)
  alias LexerFunctionType = Proc(String, NamedTuple("type": Symbol, "content": String))

  class Lexer
    @@lexers : Hash(Regex, LexerFunctionType) = {TITLE_REGEX => ->title(String), LIST_REGEX => ->list(String)}

    def self.call(data : Array(String)) : Array(Lexed)
      return data.each_with_object([] of Lexed, &self.call_appropriate_lexer)
    end

    def self.title(title_content : String) : Lexed
      {type: :title, content: title_content}
    end

    def self.list(list_content : String) : Lexed
      {type: :list, content: list_content}
    end

    def self.property(property_content : String) : Lexed
      {type: :property, content: property_content}
    end

    private def self.call_appropriate_lexer
      ->(line : String, array : Array(Lexed)) { REGEXS.each { |regex| array << @@lexers[regex].call(line) if line.match(regex) } }
    end
  end
end
