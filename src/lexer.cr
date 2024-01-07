require "./tokens"

module OrgMob
  alias Lexed = NamedTuple("type": Symbol, "content": String, "match": Regex::MatchData)

  class Lexer
    alias LexerFunctionType = Proc(String, NamedTuple("type": Symbol, "content": String))

    def call(data : Array(String)) : Array(Lexed)
      result = [] of Lexed
      data.each_with_object(result, &tokenize_string)
    end

    private def tokenize_string
      ->(line : String, result : Array(Lexed)) do
        match_data = nil
        regex = TOKENS.find { |token| (match_data = line.match(token[:regex])) }

        return if regex.nil? || match_data.nil?

        result << {type: regex[:type], content: line, match: match_data}
      end
    end
  end
end
