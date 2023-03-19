require "./regex"

module OrgMob
  alias Lexed = NamedTuple("type": Symbol, "content": String, "match": Regex::MatchData)

  class Lexer
    alias LexerFunctionType = Proc(String, NamedTuple("type": Symbol, "content": String))

    def self.call(data : Array(String)) : Array(Lexed)
      return data.each_with_object([] of Lexed, &self.call_appropriate_lexer)
    end

    def self.format(type : Symbol, content : String, match : Regex::MatchData) : Lexed
      {type: type, content: content, match: match}
    end

    private def self.call_appropriate_lexer
      ->(line : String, array : Array(Lexed)) do
        REGEXS.each do |regex|
          if match_data = line.match(regex[:regex])
            return array << self.format(regex[:type], line, match_data)
          end
        end
      end
    end
  end
end
