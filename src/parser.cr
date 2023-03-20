require "./configuration"
require "./lexer"
require "./exception"
require "json"

module OrgMob
  VERSION = "0.1.0"

  # Class to parse your org files as OrgMob format
  class Parser
    @@configuration = Configuration.new
    PARSERS = {keyword: ->parse_keywords(Array(Lexed), JSON::Builder), property: ->parse_properties(Array(Lexed), JSON::Builder)}

    def self.configure
      yield @@configuration
    end

    def self.parse(data : String) : String
      splited_data : Array(String) = data.split('\n')
      lexed_data = Lexer.call(splited_data)
      json_text = self.parse_lexed_data(lexed_data)
    rescue error : OrgMob::Exception
      return error.json_content
    else
      return json_text
    end

    def self.parse_lexed_data(data : Array(Lexed)) : String
      JSON.build do |json|
        json.object do
          self.create_base_object(data, json)
        end
      end
    end

    def self.create_base_object(data : Array(Lexed), json : JSON::Builder)
      while %i[property keyword].includes?(type = data.first[:type])
        PARSERS[type].call(data, json)
      end
    end

    def self.parse_properties(data : Array(Lexed), json : JSON::Builder)
      raise OrgMob::Exception.new("Property attribute is missing") unless beginning_properties?(data)
      json.field "properties" do
        json.object do
          while !end_properties?((element = data.shift))
            raise OrgMob::Exception.new("END Property attribute is missing") if element[:type] != :property
            match = element[:match]
            json.field match["property"], match["value"]
          end
        end
      end
    end

    def self.parse_keywords(data : Array(Lexed), json : JSON::Builder)
      json.field "keywords" do
        json.object do
          while data.first[:type] == :keyword
            match = data.shift[:match]
            json.field match["key"], match["value"]
          end
        end
      end
    end

    private def self.beginning_properties?(data : Array(Lexed))
      data.shift[:match]["property"] == "PROPERTIES"
    end

    private def self.end_properties?(element : Lexed)
      element[:content].match(/end/i)
    end
  end
end
