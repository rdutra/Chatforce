require 'spec_helper'

describe Skin do
  before :each do
    @skin = Skin.new({
      :name => "Test skin", 
      :css => "file.css"
      })
  end
  
  describe "#new" do
    it "takes two parameters and returns a skin object" do
      @skin.should be_an_instance_of Skin
    end
  end
  
  describe "#name" do
    it "returns the correct name" do
      @skin.name.should eql "Test skin"
    end
  end
  
  describe "#css" do
    it "returns the correct css" do
      @skin.css.should eql "file.css"
    end
  end
  
  describe "#getAllSkins" do
    fixtures :skins
    it "returns all skins in the DB" do
      skins = Skin.get_skins
      skins.size.should eql 2
    end
  end
end
