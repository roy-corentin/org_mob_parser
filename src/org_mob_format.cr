require "./org_mob_regex"

module OrgMob
  alias TitleFormated = Hash(Symbol, String | Int32 | Nil)
  alias ListFormated = Hash(Symbol, String)
  alias Formated = TitleFormated | ListFormated

  FORMATERS = {TITLE_REGEX => ->OrgMob::Format.format_title(String), LIST_REGEX => ->OrgMob::Format.format_list(String)}

  class Format
    def self.format_title(title_content : String) : Formated
      level = title_content.count('*')
      {type: "title", level: level, content: title_content, todo: nil, schedule: nil}.to_h
    end

    def self.format_list(list_content : String) : Formated
      {type: "list", content: list_content}.to_h.as(Formated)
    end
  end
end
