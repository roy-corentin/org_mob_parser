require "./spec_helper"

describe OrgMob::Parser do
  describe "#parse" do
    parser = OrgMob::Parser.new

    context "list text" do
      it "should parse + list" do
        expected = "{\"content\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"+\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"+\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"+\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("+ list\n+ of\n+ items").should eq(expected)
      end
      it "should parse - list" do
        expected = "{\"content\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"-\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"-\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"-\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("- list\n- of\n- items").should eq(expected)
      end
      it "should parse 1. list" do
        expected = "{\"content\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"1.\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"2.\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"3.\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("1. list\n2. of\n3. items").should eq(expected)
      end
      it "should parse 1) list" do
        expected = "{\"content\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"1)\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"2)\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"3)\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("1) list\n2) of\n3) items").should eq(expected)
      end
      it "should parse a. list" do
        expected = "{\"content\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"a.\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"b.\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"c.\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("a. list\nb. of\nc. items").should eq(expected)
      end
      it "should parse a) list" do
        expected = "{\"content\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"a)\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"b)\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"c)\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("a) list\nb) of\nc) items").should eq(expected)
      end
    end
  end
end
