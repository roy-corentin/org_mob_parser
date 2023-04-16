require "./spec_helper"

describe OrgMobParser::Parser do
  describe "#self.parse" do
    context "simple text" do
      it "should parse special character" do
        expected = "{\"content\":[{\"type\":\"paragraph\",\"children\":[{\"content\":\"I'm \",\"type\":\"basic\"},{\"content\":\"very\",\"type\":\"bold\"},{\"content\":\" nice _text_ with \",\"type\":\"basic\"},{\"content\":\"special\",\"type\":\"italic\"},{\"content\":\" character\",\"type\":\"basic\"}]}]}"
        OrgMobParser::Parser.parse("I'm *very* nice _text_ with /special/ character").should eq(expected)
      end
    end

    context "list text" do
      it "should parse + list" do
        expected = "{\"content\":[{\"type\":\"list-item\",\"bullet\":\"+\",\"children\":[{\"type\":\"paragraph\",\"item\":\"list\"},{\"type\":\"paragraph\",\"item\":\"of\"},{\"type\":\"paragraph\",\"item\":\"items\"}]}]}"
        OrgMobParser::Parser.parse("+ list\n+ of\n+ items").should eq(expected)
      end
      it "should parse - list" do
        expected = "{\"content\":[{\"type\":\"list-item\",\"bullet\":\"-\",\"children\":[{\"type\":\"paragraph\",\"item\":\"list\"},{\"type\":\"paragraph\",\"item\":\"of\"},{\"type\":\"paragraph\",\"item\":\"items\"}]}]}"
        OrgMobParser::Parser.parse("- list\n- of\n- items").should eq(expected)
      end
      it "should parse 1. list" do
        expected = "{\"content\":[{\"type\":\"list-item\",\"bullet\":\"1.\",\"children\":[{\"type\":\"paragraph\",\"item\":\"list\"},{\"type\":\"paragraph\",\"item\":\"of\"},{\"type\":\"paragraph\",\"item\":\"items\"}]}]}"
        OrgMobParser::Parser.parse("1. list\n2. of\n3. items").should eq(expected)
      end
      it "should parse 1) list" do
        expected = "{\"content\":[{\"type\":\"list-item\",\"bullet\":\"1)\",\"children\":[{\"type\":\"paragraph\",\"item\":\"list\"},{\"type\":\"paragraph\",\"item\":\"of\"},{\"type\":\"paragraph\",\"item\":\"items\"}]}]}"
        OrgMobParser::Parser.parse("1) list\n2) of\n3) items").should eq(expected)
      end
      it "should parse a. list" do
        expected = "{\"content\":[{\"type\":\"list-item\",\"bullet\":\"a.\",\"children\":[{\"type\":\"paragraph\",\"item\":\"list\"},{\"type\":\"paragraph\",\"item\":\"of\"},{\"type\":\"paragraph\",\"item\":\"items\"}]}]}"
        OrgMobParser::Parser.parse("a. list\nb. of\nc. items").should eq(expected)
      end
      it "should parse a) list" do
        expected = "{\"content\":[{\"type\":\"list-item\",\"bullet\":\"a)\",\"children\":[{\"type\":\"paragraph\",\"item\":\"list\"},{\"type\":\"paragraph\",\"item\":\"of\"},{\"type\":\"paragraph\",\"item\":\"items\"}]}]}"
        OrgMobParser::Parser.parse("a) list\nb) of\nc) items").should eq(expected)
      end
    end

    context "todo keywords configured" do
      it "should detect custom keywords" do
        OrgMobParser::Parser.configure do |c|
          c.todo_keywords = ["TODO", "TODO🚩"]
        end
        expected = "{\"content\":[{\"type\":\"header\",\"level\":1,\"todo_keyword\":\"TODO🚩\",\"priority\":null,\"children\":[{\"content\":\"Important Task\",\"type\":\"basic\"}]}]}"
        OrgMobParser::Parser.parse("* TODO🚩 Important Task").should eq(expected)
      end
    end

    context "todo keywords not custom" do
      it "should detect only default keyword" do
        OrgMobParser::Parser.configure do |c|
          c.todo_keywords = ["TODO", "[ ]"]
        end
        not_expected = "{\"content\":[{\"type\":\"header\",\"level\":1,\"todo_keyword\":\"TODO🚩\",\"priority\":null,\"children\":[{\"content\":\"Important Task\",\"type\":\"basic\"}]}]}"
        OrgMobParser::Parser.parse("* TODO🚩 Important Task").should_not eq(not_expected)
      end
    end
  end
end
