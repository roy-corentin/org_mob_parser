require "./configuration"
require "./lexer"
require "json"

module OrgMob
  VERSION = "0.1.0"

  # Class to parse your org files as OrgMob format
  class Parser
    @@configuration = Configuration.new

    def self.configure
      yield @@configuration
    end

    def self.parse(data : String) : Array(Formated)
      return self.parse_data(data.split('\n'))
    end

    private def self.parse_data(data : Array(String)) : Array(Formated)
      output = [] of Formated
      data.each_with_object(output, &self.call_appropriate_formater)
      return output
    end

    private def self.call_appropriate_formater
      ->(line : String, array : Array(Formated)) { REGEXS.each { |regex| array << FORMATERS[regex].call(line) if line.match(regex) } }
    end

    private def self.parse_todos(data : Array(String), todo_keywords : Array(String))
      regex = /^\*+\s(#{todo_keywords.join("|")})\s.*/
    end
  end
end
