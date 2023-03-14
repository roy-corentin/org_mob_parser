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

    def self.parse(data : String) : Array(Lexed)
      return self.parse_data(data.split('\n'))
    end

    private def self.parse_data(data : Array(String)) : Array(Lexed)
      output = [] of Lexed
      data.each_with_object(output, &self.call_appropriate_lexer)
      return output
    end

    private def self.call_appropriate_lexer
      ->(line : String, array : Array(Lexed)) { REGEXS.each { |regex| array << LEXERS[regex].call(line) if line.match(regex) } }
    end

    private def self.parse_todos(data : Array(String), todo_keywords : Array(String))
      regex = /^\*+\s(#{todo_keywords.join("|")})\s.*/
    end
  end
end
