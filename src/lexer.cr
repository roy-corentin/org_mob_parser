require "./regex"

module OrgMob
  alias Lexed = NamedTuple("type": Symbol, "content": String)
  alias LexerFunctionType = Proc(String, NamedTuple("type": Symbol, "content": String))

  class Lexer
    @@lexers : Hash(Regex, LexerFunctionType) = {TITLE_REGEX => ->OrgMob::Lexer.title(String), LIST_REGEX => ->OrgMob::Lexer.list(String)}

    def self.call(data : Array(String)) : Array(Lexed)
      output = [] of Lexed
      data.each_with_object(output, &self.call_appropriate_lexer)
      return output
    end

    private def self.call_appropriate_lexer
      ->(line : String, array : Array(Lexed)) { REGEXS.each { |regex| array << @@lexers[regex].call(line) if line.match(regex) } }
    end

    private def self.parse_todos(data : Array(String), todo_keywords : Array(String))
      regex = /^\*+\s(#{todo_keywords.join("|")})\s.*/
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
  end
end
