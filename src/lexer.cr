require "./regex"

module OrgMob
  alias Lexed = NamedTuple("type": Symbol, "content": String)

  LEXERS = {TITLE_REGEX => ->OrgMob::Format.format_title(String), LIST_REGEX => ->OrgMob::Format.format_list(String)}

  class Format
    def self.format_title(title_content : String) : Lexed
      level = title_content.count('*')
      {type: :title, content: title_content}
    end

    def self.format_list(list_content : String) : Lexed
      {type: :list, content: list_content}
    end
  end
end
