require "./spec_helper"

describe OrgMob::Lexer do
  describe "#self.call" do
    context "title" do
      it "should have title as type" do
        lexer = OrgMob::Lexer.new
        lexer.call(["* Title"]).first[:type].should eq(:header)
      end
    end

    context "lists" do
      context "dash list" do
        it "should have list as type" do
          lexer = OrgMob::Lexer.new
          lexer.call(["- List"]).first[:type].should eq(:list)
        end
      end

      context "+ list" do
        it "should have list as type" do
          lexer = OrgMob::Lexer.new
          lexer.call(["+ List"]).first[:type].should eq(:list)
        end
      end

      context "number list" do
        context ") list" do
          it "should have list as type" do
            lexer = OrgMob::Lexer.new
            lexer.call(["1) List"]).first[:type].should eq(:list)
          end
        end

        context ". list" do
          it "should have list as type" do
            lexer = OrgMob::Lexer.new
            lexer.call(["1. List"]).first[:type].should eq(:list)
          end
        end
      end

      context "alphabetical list" do
        context "downcase" do
          context ") list" do
            it "should have list as type" do
              lexer = OrgMob::Lexer.new
              lexer.call(["a) List"]).first[:type].should eq(:list)
            end
          end

          context ". list" do
            it "should have list as type" do
              lexer = OrgMob::Lexer.new
              lexer.call(["a. List"]).first[:type].should eq(:list)
            end
          end
        end
        context "upcase" do
          context ") list" do
            it "should have list as type" do
              lexer = OrgMob::Lexer.new
              lexer.call(["A) List"]).first[:type].should eq(:list)
            end
          end

          context ". list" do
            it "should have list as type" do
              lexer = OrgMob::Lexer.new
              lexer.call(["A. List"]).first[:type].should eq(:list)
            end
          end
        end
      end

      context "invalid list" do
        it "should have paragraph as type" do
          lexer = OrgMob::Lexer.new
          lexer.call(["1- List"]).first[:type].should eq(:paragraph)
        end
      end
    end

    context "block code" do
      context "downcase" do
        it "should have code as type" do
          lexer = OrgMob::Lexer.new
          rlexer.call(["#+begin_src elisp", "(sum 1, 2)", "#+end_src"])

          result.first[:type].should eq(:code)
          result.last[:type].should eq(:code)
        end
      end
      context "upcase" do
        it "should have code as type" do
          lexer = OrgMob::Lexer.new
          rlexer.call(["#+BEGIN_SRC elisp", "(sum 1, 2)", "#+END_SRC"])

          result.first[:type].should eq(:code)
          result.last[:type].should eq(:code)
        end
      end
    end

    context "block quote" do
      context "downcase" do
        it "should have code as type" do
          lexer = OrgMob::Lexer.new
          rlexer.call(["#+begin_quote", "I'm a quote", "#+end_quote"])

          result.first[:type].should eq(:quote)
          result.last[:type].should eq(:quote)
        end
      end
      context "upcase" do
        it "should have code as type" do
          lexer = OrgMob::Lexer.new
          rlexer.call(["#+BEGIN_quote elisp", "I'm a quote", "#+END_quote"])

          result.first[:type].should eq(:quote)
          result.last[:type].should eq(:quote)
        end
      end
    end

    context "new line" do
      it "should have new_line as type" do
        lexer = OrgMob::Lexer.new
        lexer.call([""]).first[:type].should eq(:new_line)
      end
    end

    context "paragraph" do
      it "should have paragraph as type" do
        lexer = OrgMob::Lexer.new
        lexer.call(["This is a pragraph"]).first[:type].should eq(:paragraph)
      end
    end

    context "keyword" do
      context "org keyword" do
        it "should have keyword as type" do
          lexer = OrgMob::Lexer.new
          rlexer.call(["#+title: Note Title", "#+author: Corentin Roy", "#+startup: overview"])
          result.each do |r|
            r[:type].should eq(:keyword)
          end
        end
      end
    end

    context "property" do
      context "org property" do
        it "should have property as type" do
          lexer = OrgMob::Lexer.new
          rlexer.call([":PROPERTIES:", ":ID:     be3ab0a1-01a8-46a5-bcdf-ed1b9deec0d9", ":END:"])
          result.each do |r|
            r[:type].should eq(:property)
          end
        end
      end
    end
  end
end
