require 'spec_helper'

describe Buddy do
  before :each do
    @buddy = Buddy.new({
      :name => "Test Buddy", 
      :nickname => "Test Nickname", 
      :status =>"Available", 
      :salesforce_id => "Test Salesforce ID", 
      :small_photo_url => "Test small photo", 
      :org_id => 12345
      })
  end
  
  describe "#new" do
    it "takes six parameters and returns a Buddy object" do
      @buddy.should be_an_instance_of Buddy
    end
  end
  
  describe "#name" do
    it "returns the correct name" do
      @buddy.name.should eql "Test Buddy"
    end
  end
  
  describe "#nickname" do
    it "returns the correct nickname" do
      @buddy.nickname.should eql "Test Nickname"
    end
  end
  
  describe "#status" do
    it "returns the correct status" do
      @buddy.status.should eql "Available"
    end
  end
  
  describe "#salesforce_id" do
    it "returns the correct salesforce_id" do
      @buddy.salesforce_id.should eql "Test Salesforce ID"
    end
  end
  
  describe "#smallphotourl" do
    it "returns the correct smallphotourl" do
      @buddy.small_photo_url.should eql "Test small photo"
    end
  end
  
  describe "#orgid" do
    it "returns the correct org id" do
      @buddy.org_id.should eql 12345
    end
  end
  
  describe "#getBuddybyId" do
    fixtures :buddies
    it "returns a buddy from the DB given an id" do
      buddy = Buddy.get_buddy_by_id 1
      buddy.name.should eql "Jhon Falcon"
    end
  end
  
  describe "#getAllBuddiesforOrg" do
    fixtures :buddies
    it "returns all buddies for a given org" do
      buddies = Buddy.get_all_by_org 12345
      buddies.size.should eql 2
    end
  end
  
  describe "#setStatus" do
    fixtures :buddies
    it "changes the status of a given buddy" do
      buddy = Buddy.get_buddy_by_id 1
      buddy.status.should eql "Available"
      Buddy.set_status 1,"Offline"
      buddy = Buddy.get_buddy_by_id 1
      buddy.status.should eql "Offline"
    end
  end
  
  describe "#get_buddy_by_Sfid" do
    fixtures :buddies
    it "gets a user by its salesforce id" do
      buddy = Buddy.get_buddy_by_Sfid "111"
      buddy.name.should eql "Jhon Falcon"
    end
  end
  
  describe "#exists_buddy" do
    fixtures :buddies
    it "determines if a user exists by it's salesfoce id" do
      exists = Buddy.exists_buddy "111"
      exists.should eql true
    end
  end
  
  describe "#add_buddy" do
    fixtures :buddies
    it "adds a buddy to the db" do 
      options = {:name => "Test Buddy", :nickname => "Test nick", :org_id => "111", :salesforce_id => "2345"}
      Buddy.add_buddy options
      exists = Buddy.exists_buddy "2345"
      exists.should eql true
    end
  end
  
  describe "#get_buddies_by_org" do
    fixtures :buddies
    it "gets buddies by org" do
      buddies = Buddy.get_all_by_org 12345
      buddies.size.should eql 2
    end
  end
  
end
