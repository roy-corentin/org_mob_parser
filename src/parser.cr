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
      lexed_data = Lexer.call(data.split('\n'))
      return lexed_data
    end
  end
end
