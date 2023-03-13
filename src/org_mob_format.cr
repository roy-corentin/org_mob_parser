require "./org_mob_regex"

module OrgMob
  alias KeyType = Symbol
  alias ValueType = String | Int32 | Nil
  alias Lexed = Hash(KeyType, ValueType)

  FORMATERS = {TITLE_REGEX => ->OrgMob::Format.format_title(String)}

  class Format
    def self.format_title(title_content : String) : Hash(KeyType, ValueType)
      level = title_content.count('*')
      {type: "title", level: level, content: title_content, todo: nil, schedule: nil}.to_h
    end
  end
end
