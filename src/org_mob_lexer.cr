# TODO: Write documentation for `OrgMobLexer`
require "./org_mob_configuration"
require "./org_mob_format"
require "json"

module OrgMob
  VERSION = "0.1.0"

  class Lexer
    @@configuration = Configuration.new

    def self.configure
      yield @@configuration
    end

    def self.parse(data : String)
      return self.parse_data(data.split('\n')).to_json
    end

    private def self.parse_data(data : Array(String)) : Array(Hash(KeyType, ValueType))
      output = [] of Lexed
      data.each_with_object(output, &self.call_appropriate_formater)
      return output
    end

    private def self.call_appropriate_formater
      ->(line : String, array : Array(Lexed)) { REGEXS.each { |regex| array << FORMATERS[regex].call(line) if line.match(regex) } }
    end

    private def self.parse_todos(data : Array(String), todo_keywords : Array(String))
      regex = /^\*+\s(#{todo_keywords.join("|")})\s.*/
    end
  end
end
