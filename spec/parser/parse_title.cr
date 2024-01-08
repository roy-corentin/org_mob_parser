require "./spec_helper"

describe OrgMob::Parser do
  describe "#parse" do
    parser = OrgMob::Parser.new

    context "todo keywords not custom" do
      it "should detect only default keyword" do
        not_expected = "{\"content\":[{\"type\":\"header\",\"level\":1,\"todo_keyword\":\"TODO🚩\",\"priority\":null,\"children\":[{\"content\":\"Important Task\",\"type\":\"basic\"}]}]}"
        parser.parse("* TODO🚩 Important Task").should_not eq(not_expected)
      end
    end

    context "todo keywords custom" do
      parser_custom = OrgMob::Parser.new
      parser_custom.configure do |c|
        c.todo_keywords = ["TODO", "TODO🚩"]
      end

      it "should detect custom keywords" do
        expected = "{\"content\":[{\"type\":\"header\",\"level\":1,\"todo_keyword\":\"TODO🚩\",\"priority\":null,\"children\":[{\"content\":\"Important Task\",\"type\":\"basic\"}]}]}"
        parser_custom.parse("* TODO🚩 Important Task").should eq(expected)
      end
    end
  end
end
