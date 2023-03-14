require "./regex"

module OrgMob
  alias Lexed = NamedTuple("type": Symbol, "content": String)

  LEXERS = {TITLE_REGEX => ->OrgMob::Lexer.title(String), LIST_REGEX => ->OrgMob::Lexer.list(String)}

  class Lexer
    def self.title(title_content : String) : Lexed
      level = title_content.count('*')
      {type: :title, content: title_content}
    end

    def self.list(list_content : String) : Lexed
      {type: :list, content: list_content}
    end
  end
end
