require "./spec_helper"

describe OrgMob::Parser do
  describe "#parse" do
    parser = OrgMob::Parser.new

    context "simple text" do
      it "shoudl parse text in one child" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"paragraph\",\"children\":[{\"content\":\"I'm a simple text\",\"type\":\"basic\"}]}]}"
        parser.parse("I'm a simple text")
      end
    end

    context "special text" do
      it "should parse special character" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"paragraph\",\"children\":[{\"content\":\"I'm \",\"type\":\"basic\"},{\"content\":\"very\",\"type\":\"bold\"},{\"content\":\" nice _text_ with \",\"type\":\"basic\"},{\"content\":\"special\",\"type\":\"italic\"},{\"content\":\" character\",\"type\":\"basic\"}]}]}"
        parser.parse("I'm *very* nice _text_ with /special/ character").should eq(expected)
      end
    end

    context "list text" do
      it "should parse + list" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"+\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"+\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"+\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("+ list\n+ of\n+ items").should eq(expected)
      end
      it "should parse - list" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"-\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"-\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"-\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("- list\n- of\n- items").should eq(expected)
      end
      it "should parse 1. list" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"1.\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"2.\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"3.\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("1. list\n2. of\n3. items").should eq(expected)
      end
      it "should parse 1) list" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"1)\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"2)\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"3)\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("1) list\n2) of\n3) items").should eq(expected)
      end
      it "should parse a. list" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"a.\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"b.\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"c.\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("a. list\nb. of\nc. items").should eq(expected)
      end
      it "should parse a) list" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"plain-list\",\"children\":[{\"type\":\"list-item\",\"bullet\":\"a)\",\"children\":[{\"content\":\"list\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"b)\",\"children\":[{\"content\":\"of\",\"type\":\"basic\"}]},{\"type\":\"list-item\",\"bullet\":\"c)\",\"children\":[{\"content\":\"items\",\"type\":\"basic\"}]}]}]}"
        parser.parse("a) list\nb) of\nc) items").should eq(expected)
      end
    end

    context "todo keywords not custom" do
      it "should detect only default keyword" do
        not_expected = "{\"header\":{},\"body\":[{\"type\":\"header\",\"level\":1,\"todo_keyword\":\"TODO🚩\",\"priority\":null,\"children\":[{\"content\":\"Important Task\",\"type\":\"basic\"}]}]}"
        parser.parse("* TODO🚩 Important Task").should_not eq(not_expected)
      end
    end

    context "todo keywords custom" do
      parser_custom = OrgMob::Parser.new
      parser_custom.configure do |c|
        c.todo_keywords = ["TODO", "TODO🚩"]
      end

      it "should detect custom keywords" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"header\",\"level\":1,\"todo_keyword\":\"TODO🚩\",\"priority\":null,\"children\":[{\"content\":\"Important Task\",\"type\":\"basic\"}]}]}"
        parser_custom.parse("* TODO🚩 Important Task").should eq(expected)
      end
    end

    context "file header" do
      it "should parse file header" do
        expected = "{\"header\":{\"properties\":[{\"ID\":\"5d0acecf-a5b1-4468-afe5-8f34fbc63259\"}],\"keywords\":[{\"title\":\" Internet Protocol Suite\"}]},\"body\":[]}"
        parser.parse(":PROPERTIES:\n:ID: 5d0acecf-a5b1-4468-afe5-8f34fbc63259\n:END:\n#+title: Internet Protocol Suite").should eq(expected)
        parser.parse(":properties:\n:ID: 5d0acecf-a5b1-4468-afe5-8f34fbc63259\n:end:\n#+title: Internet Protocol Suite").should eq(expected)
      end
    end

    context "block code" do
      it "should parse block doc" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"block_src\",\"language\":\"ruby\",\"children\":\"puts 'Hello World'\"}]}"
        parser.parse("#+BEGIN_SRC ruby\nputs 'Hello World'\n#+END_SRC").should eq(expected)
        parser.parse("#+begin_src ruby\nputs 'Hello World'\n#+end_src").should eq(expected)
      end
    end

    context "block quote" do
      it "should parse block quote" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"block_quote\",\"children\":[{\"type\":\"paragraph\",\"children\":[{\"content\":\"This is a block quote\",\"type\":\"basic\"}]}]}]}"
        parser.parse("#+BEGIN_QUOTE\nThis is a block quote\n#+END_QUOTE").should eq(expected)
        parser.parse("#+begin_quote\nThis is a block quote\n#+end_quote").should eq(expected)
      end
    end

    context "block example" do
      it "should parse block example" do
        expected = "{\"header\":{},\"body\":[{\"type\":\"block_example\",\"children\":[{\"type\":\"paragraph\",\"children\":[{\"content\":\"This is a block example\",\"type\":\"basic\"}]}]}]}"
        parser.parse("#+BEGIN_EXAMPLE\nThis is a block example\n#+END_EXAMPLE").should eq(expected)
        parser.parse("#+begin_example\nThis is a block example\n#+end_example").should eq(expected)
      end
    end
  end
end
