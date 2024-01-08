require "./tokens"

module OrgMob
  alias Lexed = NamedTuple("type": Symbol, "content": String, "match": Regex::MatchData)

  class Lexer
    alias LexerFunctionType = Proc(String, NamedTuple("type": Symbol, "content": String))

    def call(data : Array(String)) : Array(Lexed)
      data.map { |line| tokenize_string(line) }.compact
    end

    private def tokenize_string(line : String) : Lexed?
      match_data = nil
      regex = TOKENS.find { |token| (match_data = line.match(token[:regex])) }

      (regex && match_data) ? {type: regex[:type], content: line, match: match_data} : nil
    end
  end
end
