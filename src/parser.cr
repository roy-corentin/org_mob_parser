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
      json_text = parse_lexed_data_to_json(lexed_data)
    rescue error : OrgMob::Exception
      error.json_content
    else
      json_text
    end

    private def parse_lexed_data_to_json(data : Array(Lexed)) : String
      JSON.build do |json_builder|
        json_builder.object do
          create_header(data, json_builder)
          json_builder.field "content" do
            json_builder.array do
              parse_from_object(data, json_builder)
            end
          end
        end
      end
    end

    private def create_header(data : Array(Lexed), json_builder : JSON::Builder)
      while %i[property keyword].includes?(token_type = data.first[:type])
        parsers_by_type[token_type].call(data, json_builder)
      end
    end

    private def parsers_by_type
      {
        keyword:   ->parse_keywords(Array(Lexed), JSON::Builder),
        property:  ->parse_properties(Array(Lexed), JSON::Builder),
        header:    ->parse_header(Array(Lexed), JSON::Builder),
        paragraph: ->parse_paragraph(Array(Lexed), JSON::Builder),
        list:      ->parse_list(Array(Lexed), JSON::Builder),
      }
    end

    private def parse_keywords(data : Array(Lexed), json_builder : JSON::Builder)
      json_builder.field "keywords" do
        json_builder.object do
          while data.any? && data.first[:type] == :keyword
            match = data.shift[:match]
            json_builder.field match["key"], match["value"]
          end
        end
      end
    end

    private def parse_properties(data : Array(Lexed), json_builder : JSON::Builder)
      raise OrgMob::Exception.new("Start property token is missing") unless beginning_properties?(data)

      json_builder.field "properties" do
        json_builder.object do
          while !end_properties?(data.first)
            token = data.shift
            raise OrgMob::Exception.new("END Property attribute is missing") if token.nil? || token[:type] != :property

            match = token[:match]
            json_builder.field match["property"], match["value"]
          end
          data.shift
        end
      end
    end

    private def parse_header(data : Array(Lexed), json_builder : JSON::Builder)
      token = data.shift
      level = token[:match]["header_chars"].size
      todo_match = token[:match]["title"].match /^(?<todo_keyword>#{@configuration.keywords})\s(?<title>.*)/

      title_content = if todo_match
                        priority_match = token[:match]["title"].match /\[\#(?<priority_level>[A-Z])\]\s*(?<title>.*)/
                        priority_match ? priority_match["title"] : todo_match["title"]
                      else
                        token[:match]["title"]
                      end

      @current_level = level

      json_builder.object do
        json_builder.field "type", token[:type]
        json_builder.field "level", level
        json_builder.field "todo_keyword", todo_match ? todo_match["todo_keyword"] : nil
        json_builder.field "priority", priority_match ? priority_match["priority_level"] : nil

        json_builder.field "children" { parse_text(title_content, json_builder) }
      end
    end

    private def parse_paragraph(data : Array(Lexed), json_builder : JSON::Builder)
      token = data.shift
      json_builder.object do
        json_builder.field "type", token[:type]
        json_builder.field "children" do
          parse_text(token[:content], json_builder)
        end
      end
    end

    private def parse_list(data : Array(Lexed), json_builder : JSON::Builder)
      json_builder.object do
        json_builder.field "type", "plain-list"
        json_builder.field "children" do
          json_builder.array do
            while data.any? && data.first[:type] == :list
              json_builder.object do
                token = data.shift
                json_builder.field "type", "list-item"
                json_builder.field "bullet", token[:match]["bullet"]
                json_builder.field "children" do
                  parse_text(token[:match]["item"], json_builder)
                end
              end
            end
          end
        end
      end
    end

    private def parse_text(text : String, json_builder : JSON::Builder)
      json_builder.array do
        until text.empty?
          case text
          when /(?<before>.*?)\*(?<inside>[^*]+)\*(?<after>.*)/
            json_builder.object do
              json_builder.field "content", $~["before"]
              json_builder.field "type", "basic"
            end
            json_builder.object do
              json_builder.field "content", $~["inside"]
              json_builder.field "type", "bold"
            end
            text = $~["after"]
          when /(?<before>.*?)\/(?<inside>[^\/]+)\/(?<after>.*)/
            json_builder.object do
              json_builder.field "content", $~["before"]
              json_builder.field "type", "basic"
            end
            json_builder.object do
              json_builder.field "content", $~["inside"]
              json_builder.field "type", "italic"
            end
            text = $~["after"]
          when /(?<before>.*?)_(?<inside>[^_]+)_(?<after>.*)/
            json_builder.object do
              json_builder.field "content", $~["before"]
              json_builder.field "type", "basic"
            end
            json_builder.object do
              json_builder.field "content", $~["inside"]
              json_builder.field "type", "underline"
            end
            text = $~["after"]
          else
            json_builder.object do
              json_builder.field "content", text
              json_builder.field "type", "basic"
            end
            text = ""
          end
        end
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

    private def parse_from_object(data : Array(Lexed), json_builder : JSON::Builder)
      while data.any? && ((type = data.first[:type]))
        parsers_by_type[type].call(data, json_builder)
      end
    end
  end
end
