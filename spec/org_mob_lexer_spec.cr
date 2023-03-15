require "./spec_helper"

describe OrgMob::Lexer do
  describe "#self.call" do
    context "title" do
      it "should have title as type" do
        OrgMob::Lexer.call(["* Title"]).first[:type].should eq(:title)
      end
    end

    context "lists" do
      context "dash list" do
        it "should have list as type" do
          OrgMob::Lexer.call(["- List"]).first[:type].should eq(:list)
        end
      end

      context "+ list" do
        it "should have list as type" do
          OrgMob::Lexer.call(["+ List"]).first[:type].should eq(:list)
        end
      end

      context "number list" do
        context ") list" do
          it "should have list as type" do
            OrgMob::Lexer.call(["1) List"]).first[:type].should eq(:list)
          end
        end

        context ". list" do
          it "should have list as type" do
            OrgMob::Lexer.call(["1. List"]).first[:type].should eq(:list)
          end
        end
      end

      context "alphabetical list" do
        context "downcase" do
          context ") list" do
            it "should have list as type" do
              OrgMob::Lexer.call(["a) List"]).first[:type].should eq(:list)
            end
          end

          context ". list" do
            it "should have list as type" do
              OrgMob::Lexer.call(["a. List"]).first[:type].should eq(:list)
            end
          end
        end
        context "upcase" do
          context ") list" do
            it "should have list as type" do
              OrgMob::Lexer.call(["A) List"]).first[:type].should eq(:list)
            end
          end

          context ". list" do
            it "should have list as type" do
              OrgMob::Lexer.call(["A. List"]).first[:type].should eq(:list)
            end
          end
        end
      end

      context "invalid list" do
        it "should have paragraph as type" do
          OrgMob::Lexer.call(["1- List"]).first[:type].should eq(:paragraph)
        end
      end
    end
  end
end
