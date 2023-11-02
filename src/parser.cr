require "./configuration"
require "./lexer"
require "./exception"
require "json"

module OrgMob
  VERSION = "0.1.2"

  # Class to parse your org files as OrgMob format
  class Parser
    def initialize
      @current_level = 0
      @configuration = Configuration.new
      @lexer = Lexer.new
    end

    def configure
      yield @configuration
    end

    def parse(data : String) : String
      splited_data : Array(String) = data.split('\n')
      lexed_data = @lexer.call(splited_data)
      json_text = self.parse_lexed_data(lexed_data)
    rescue error : OrgMob::Exception
      return error.json_content
    else
      return json_text
    end

    def parse_lexed_data(data : Array(Lexed)) : String
      JSON.build do |json|
        json.object do
          self.create_header(data, json)
          json.field "content" do
            json.array do
              parse_from_object(data, json)
            end
          end
        end
      end
    end

    def parse_properties(data : Array(Lexed), json : JSON::Builder)
      raise OrgMob::Exception.new("Property attribute is missing") unless beginning_properties?(data)
      json.field "properties" do
        json.object do
          while data.any? && !end_properties?(data.first)
            element = data.shift
            raise OrgMob::Exception.new("END Property attribute is missing") if element[:type] != :property
            match = element[:match]
            json.field match["property"], match["value"]
          end
          data.shift
        end
      end
    end

    def parse_keywords(data : Array(Lexed), json : JSON::Builder)
      json.field "keywords" do
        json.object do
          while data.any? && data.first[:type] == :keyword
            match = data.shift[:match]
            json.field match["key"], match["value"]
          end
        end
      end
    end

    def parse_header(data : Array(Lexed), json : JSON::Builder)
      element = data.shift
      level = element[:match]["level"].size
      todo_match = element[:match]["title"].match /^(?<todo_key>#{@configuration.keywords})\s?(?<title>.*)/
      priority_match = element[:match]["title"].match /\[\#(?<priority>[A-Z])\]\s*(?<title>.*)/
      value = todo_match ? (priority_match ? priority_match["title"] : todo_match["title"]) : element[:match]["title"]

      @current_level = level

      json.object do
        json.field "type", element[:type]
        json.field "level", level
        json.field "todo_keyword", todo_match ? todo_match["todo_key"] : nil
        json.field "priority", priority_match ? priority_match["priority"] : nil

        json.field "children" do
          self.parse_text(value, json)
        end
      end
    end

    def parse_paragraph(data : Array(Lexed), json : JSON::Builder)
      element = data.shift
      json.object do
        json.field "type", element[:type]
        json.field "children" do
          self.parse_text(element[:content], json)
        end
      end
    end

    def parse_list(data : Array(Lexed), json : JSON::Builder)
      json.object do
        json.field "type", "plain-list"
        json.field "children" do
          json.array do
            while data.any? && data.first[:type] == :list
              json.object do
                element = data.shift
                json.field "type", "list-item"
                json.field "bullet", element[:match]["bullet"]
                json.field "children" do
                  self.parse_text(element[:match]["item"], json)
                end
              end
            end
          end
        end
      end
    end

    def parse_text(text : String, json : JSON::Builder)
      json.array do
        until text.empty?
          case text
          when /(?<before>.*?)\*(?<inside>[^*]+)\*(?<after>.*)/
            json.object do
              json.field "content", $~["before"]
              json.field "type", "basic"
            end
            json.object do
              json.field "content", $~["inside"]
              json.field "type", "bold"
            end
            text = $~["after"]
          when /(?<before>.*?)\/(?<inside>[^\/]+)\/(?<after>.*)/
            json.object do
              json.field "content", $~["before"]
              json.field "type", "basic"
            end
            json.object do
              json.field "content", $~["inside"]
              json.field "type", "italic"
            end
            text = $~["after"]
          when /(?<before>.*?)_(?<inside>[^_]+)_(?<after>.*)/
            json.object do
              json.field "content", $~["before"]
              json.field "type", "basic"
            end
            json.object do
              json.field "content", $~["inside"]
              json.field "type", "underline"
            end
            text = $~["after"]
          else
            json.object do
              json.field "content", text
              json.field "type", "basic"
            end
            text = ""
          end
        end
      end
    end

    private def parsers_by_type
      {keyword: ->parse_keywords(Array(Lexed), JSON::Builder), property: ->parse_properties(Array(Lexed), JSON::Builder), header: ->parse_header(Array(Lexed), JSON::Builder), paragraph: ->parse_paragraph(Array(Lexed), JSON::Builder), list: ->parse_list(Array(Lexed), JSON::Builder)}
    end

    private def create_header(data : Array(Lexed), json : JSON::Builder)
      while %i[property keyword].includes?(type = data.first[:type])
        parsers_by_type[type].call(data, json)
      end
    end

    private def beginning_properties?(data : Array(Lexed))
      data.shift[:match]["property"] == "PROPERTIES"
    end

    private def end_properties?(element : Lexed)
      element[:content].match(/end/i)
    end

    private def first_header?
      @current_level == 0
    end

    private def parse_from_object(data : Array(Lexed), json : JSON::Builder)
      while data.any? && ((type = data.first[:type]))
        parsers_by_type[type].call(data, json)
      end
    end
  end
end
