require "./spec_helper"

describe OrgMob::Parser do
  describe "#self.parse" do
    context "parse title" do
      it "should have title as type" do
        OrgMob::Parser.parse("* Title").first[:type].should eq("title")
      end
    end

    context "parse list" do
      context "dash list" do
        it "should have list as type" do
          OrgMob::Parser.parse("- List").first[:type].should eq("list")
        end
      end

      context "+ list" do
        it "should have list as type" do
          OrgMob::Parser.parse("+ List").first[:type].should eq("list")
        end
      end

      context "1) list" do
        it "should have list as type" do
          OrgMob::Parser.parse("1) List").first[:type].should eq("list")
        end
      end

      context "1. list" do
        it "should have list as type" do
          OrgMob::Parser.parse("1. List").first[:type].should eq("list")
        end
      end
    end
  end
end
