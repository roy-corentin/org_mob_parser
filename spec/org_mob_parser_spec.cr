require "./spec_helper"

describe OrgMob::Parser do
  describe "#self.parse" do
    context "parse title" do
      it "should have title as type" do
        OrgMob::Parser.parse("* Title").first[:type].should eq(:title)
      end
    end

    context "parse list" do
      context "dash list" do
        it "should have list as type" do
          OrgMob::Parser.parse("- List").first[:type].should eq(:list)
        end
      end

      context "+ list" do
        it "should have list as type" do
          OrgMob::Parser.parse("+ List").first[:type].should eq(:list)
        end
      end

      context "number list" do
        context ") list" do
          it "should have list as type" do
            OrgMob::Parser.parse("1) List").first[:type].should eq(:list)
          end
        end

        context ". list" do
          it "should have list as type" do
            OrgMob::Parser.parse("1. List").first[:type].should eq(:list)
          end
        end
      end

      context "alphabetical list" do
        context "downcase" do
          context ") list" do
            it "should have list as type" do
              OrgMob::Parser.parse("a) List").first[:type].should eq(:list)
            end
          end

          context ". list" do
            it "should have list as type" do
              OrgMob::Parser.parse("a. List").first[:type].should eq(:list)
            end
          end
        end
        context "upcase" do
          context ") list" do
            it "should have list as type" do
              OrgMob::Parser.parse("A) List").first[:type].should eq(:list)
            end
          end

          context ". list" do
            it "should have list as type" do
              OrgMob::Parser.parse("A. List").first[:type].should eq(:list)
            end
          end
        end
      end

      context "invalid list" do
        it "should be empty" do
          OrgMob::Parser.parse("1- List").empty?.should be_true
        end
      end
    end
  end
end
