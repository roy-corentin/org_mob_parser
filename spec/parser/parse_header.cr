require "./spec_helper"

describe OrgMob::Parser do
  describe "#parse" do
    parser = OrgMob::Parser.new

    context "file header" do
      it "should parse file header" do
        expected = "{\"content\":[{\"type\":\"file-header\",\"children\":[{\"content\":\"File Header\",\"type\":\"basic\"}]}]}"
        parser.parse(":PROPERTIES:\n:ID: 5d0acecf-a5b1-4468-afe5-8f34fbc63259\n:END:\n#+title: Internet Protocol Suite").should eq(expected)
      end
    end
  end
end
