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
      org_lines = get_org_lines(data)
      lexed_data = @lexer.call(org_lines)
      json_text = lexed_data_to_json(lexed_data)
    rescue error : OrgMob::Exception
      error.json_content
    else
      json_text
    end

    private def lexed_data_to_json(data : Array(Lexed)) : String
      JSON.build do |json_builder|
        json_builder.object do
          parse_head(data, json_builder)
          parse_body(data, json_builder)
        end
      end
    end

    private def parse_head(data : Array(Lexed), json_builder : JSON::Builder)
      json_builder.field "header" do
        json_builder.object do
          if ((token_type = data.first[:type])) == :property
            parse_properties(data, json_builder)
          end
          if ((token_type = data.first[:type])) == :keyword
            parse_keywords(data, json_builder)
          end
        end
      end
    end

    private def parse_body(data : Array(Lexed), json_builder : JSON::Builder)
      json_builder.field "body" do
        json_builder.array do
          while data.any? && ((token_type = data.first[:type]))
            parsers_by_type[token_type].call(data, json_builder)
          end
        end
      end
    end

    private def parsers_by_type
      {
        property:  ->parse_properties(Array(Lexed), JSON::Builder),
        keyword:   ->parse_keywords(Array(Lexed), JSON::Builder),
        header:    ->parse_header(Array(Lexed), JSON::Builder),
        paragraph: ->parse_paragraph(Array(Lexed), JSON::Builder),
        list:      ->parse_list(Array(Lexed), JSON::Builder),
        block:     ->parse_block(Array(Lexed), JSON::Builder),
        table:     ->parse_table(Array(Lexed), JSON::Builder),
        new_line:  ->parse_new_line(Array(Lexed), JSON::Builder),
      }
    end

    private def parse_properties(data : Array(Lexed), json_builder : JSON::Builder)
      raise OrgMob::Exception.new("Start property token is missing") unless beginning_properties?(data)

      json_builder.field "properties" do
        json_builder.array do
          while data.any? && !end_properties?(data.first)
            token = data.shift

            match = token[:match]
            json_builder.object do
              json_builder.field match["property"], match["value"]
            end
          end
          raise OrgMob::Exception.new("END Property attribute is missing") if !data.any? || !end_properties?(data.shift)
        end
      end
    end

    private def parse_keywords(data : Array(Lexed), json_builder : JSON::Builder)
      json_builder.field "keywords" do
        json_builder.array do
          while data.any? && data.first[:type] == :keyword
            token = data.shift
            match = token[:match]
            json_builder.object do
              json_builder.field match["key"], match["value"]
            end
          end
        end
      end
    end

    private def parse_header(data : Array(Lexed), json_builder : JSON::Builder)
      token = data.shift
      title = token[:match]["title"]
      level = token[:match]["stars"].size
      todo_match = token[:match]["title"].match /^(?<todo_keyword>#{@configuration.keywords})\s(?<title>.*)/

      title_content = if todo_match
                        priority_match = title.match /\[\#(?<priority_level>[A-Z])\]\s*(?<title>.*)/
                        priority_match ? priority_match["title"] : todo_match["title"]
                      else
                        title
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
              parse_list_item(data, json_builder)
            end
          end
        end
      end
    end

    private def parse_list_item(data : Array(Lexed), json_builder : JSON::Builder)
      json_builder.object do
        token = data.shift
        json_builder.field "type", "list-item"
        json_builder.field "bullet", token[:match]["bullet"]
        json_builder.field "children" do
          parse_text(token[:match]["item"], json_builder)
        end
      end
    end

    private def parse_block(data : Array(Lexed), json_builder : JSON::Builder)
      raise OrgMob::Exception.new("Block start token is missing") unless beginning_block?(data.first)

      begin_block = data.shift
      block_type = begin_block[:match]["block_type"]

      json_builder.object do
        json_builder.field "type", "block_#{block_type.downcase}"
        parse_block_code_options(begin_block, json_builder) if block_type.match(/^src$/i)
        if block_type.match(/^(quote|example|comment)$/i)
          json_builder.field "children" do
            parse_block_paragraph_content(data, json_builder)
          end
        else
          json_builder.field "children", parse_block_basic_content(data, json_builder)
        end
      end
    end

    private def parse_block_basic_content(data : Array(Lexed), json_builder : JSON::Builder)
      content = ""
      while data.any? && !end_block?(data.first)
        content += data.shift[:content]
      end
      raise OrgMob::Exception.new("Block end token is missing") if !data.any? || !end_block?(data.shift)
      content
    end

    private def parse_block_paragraph_content(data : Array(Lexed), json_builder : JSON::Builder)
      json_builder.array do
        while data.any? && !end_block?(data.first)
          parse_paragraph(data, json_builder)
        end
        raise OrgMob::Exception.new("Block end token is missing") if !data.any? || !end_block?(data.shift)
      end
    end

    private def parse_block_code_options(begin_block : Lexed, json_builder : JSON::Builder)
      options = begin_block[:match]["options"].split
      json_builder.field "language", options.shift
    end

    private def parse_table(data : Array(Lexed), json_builder : JSON::Builder)
      first_row = data.shift
      header = [] of String
      rows = [] of Array(String)

      if next_element_is_header_separation?(data)
        header = first_row[:match]["row"].split("|").map(&.strip)
        data.shift
      else
        rows << first_row[:match]["row"].split("|").map(&.strip)
      end

      while data.any? && data.first[:type] == :table
        rows << data.shift[:match]["row"].split("|").map(&.strip)
      end

      json_builder.object do
        json_builder.field "type", "table"
        json_builder.field "children" do
          json_builder.object do
            json_builder.field "table-header" do
              json_builder.array do
                header.map { |cell| parse_text(cell, json_builder) }
              end
            end
            json_builder.field "table-rows" { parse_rows(rows, json_builder) }
          end
        end
      end
    end

    private def parse_rows(rows : Array(Array(String)), json_builder : JSON::Builder)
      json_builder.array do
        rows.each do |row|
          json_builder.object do
            json_builder.field "children" do
              json_builder.array { row.each { |cell| parse_text(cell, json_builder) } }
            end
          end
        end
      end
    end

    private def next_element_is_header_separation?(data : Array(Lexed))
      data.first[:content].match /^\|(-\+?)+\|$/
    end

    private def parse_new_line(data : Array(Lexed), json_builder : JSON::Builder)
      data.shift
      json_builder.object do
        json_builder.field "type", "new-line"
      end
    end

    private def parse_text(text : String, json_builder : JSON::Builder)
      json_builder.array do
        until text.empty?
          case text
          when TEXT_WITH_BOLD_CONTENT
            parse_text_regex_to_object("bold", $~, json_builder)
            text = $~["after"]
          when TEXT_WITH_ITALIC_CONTENT
            parse_text_regex_to_object("italic", $~, json_builder)
            text = $~["after"]
          when TEXT_WITH_UNDERLINE_CONTENT
            parse_text_regex_to_object("underline", $~, json_builder)
            text = $~["after"]
          when TEXT_WITH_VERBATIM_CONTENT
            parse_text_regex_to_object("verbatim", $~, json_builder)
            text = $~["after"]
          when TEXT_WITH_CODE_CONTENT
            parse_text_regex_to_object("code", $~, json_builder)
            text = $~["after"]
          else
            parse_basic_text_to_object(text, json_builder)
            text = ""
          end
        end
      end
    end

    private def beginning_properties?(data : Array(Lexed))
      data.shift[:match]["property"].match(/^properties$/i)
    end

    private def end_properties?(element : Lexed)
      element[:type] == :property && element[:match]["property"].match(/^end$/i)
    end

    private def beginning_block?(element : Lexed)
      element[:match]["type"].match(/^begin$/i)
    end

    private def end_block?(element : Lexed)
      element[:type] == :block && element[:match]["type"].match(/^end$/i)
    end

    private def first_header?
      @current_level == 0
    end

    private def parse_text_regex_to_object(emphasis_type : String, match_data : Regex::MatchData, json_builder : JSON::Builder)
      json_builder.object do
        json_builder.field "content", match_data["before"]
        json_builder.field "type", "basic"
      end
      json_builder.object do
        json_builder.field "content", match_data["inside"]
        json_builder.field "type", emphasis_type
      end
    end

    private def parse_basic_text_to_object(text : String, json_builder : JSON::Builder)
      json_builder.object do
        json_builder.field "content", text
        json_builder.field "type", "basic"
      end
    end

    private def get_org_lines(data : String) : Array(String)
      if File.exists?(data)
        data = File.read(data)
      end
      data.split('\n')
    end
  end
end
