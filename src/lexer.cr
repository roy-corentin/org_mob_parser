require "./regex"

module OrgMob
  alias Lexed = NamedTuple("type": Symbol, "content": String, "match": Regex::MatchData)

  class Lexer
    alias LexerFunctionType = Proc(String, NamedTuple("type": Symbol, "content": String))

    def call(data : Array(String)) : Array(Lexed)
      return data.each_with_object([] of Lexed, &call_lexer_with_appropriate_parameters)
    end

    private def call_lexer_with_appropriate_parameters
      ->(line : String, array : Array(Lexed)) do
        REGEXS.each do |regex|
          if match_data = line.match(regex[:regex])
            return array << format(regex[:type], line, match_data)
          end
        end
      end
    end

    private def format(type : Symbol, content : String, match : Regex::MatchData) : Lexed
      {type: type, content: content, match: match}
    end
  end
end
