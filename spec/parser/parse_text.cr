require "./spec_helper"

describe OrgMob::Parser do
  describe "#parse" do
    parser = OrgMob::Parser.new

    context "simple text" do
      it "shoudl parse text in one child" do
        expected = "{\"content\":[{\"type\":\"paragraph\",\"children\":[{\"content\":\"I'm a simple text\",\"type\":\"basic\"}]}]}"
        parser.parse("I'm a simple text")
      end
    end

    context "special text" do
      it "should parse special character" do
        expected = "{\"content\":[{\"type\":\"paragraph\",\"children\":[{\"content\":\"I'm \",\"type\":\"basic\"},{\"content\":\"very\",\"type\":\"bold\"},{\"content\":\" nice _text_ with \",\"type\":\"basic\"},{\"content\":\"special\",\"type\":\"italic\"},{\"content\":\" character\",\"type\":\"basic\"}]}]}"
        parser.parse("I'm *very* nice _text_ with /special/ character").should eq(expected)
      end
    end
  end
end
