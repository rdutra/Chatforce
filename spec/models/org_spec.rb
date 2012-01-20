require 'spec_helper'

describe Org do
  before :each do
    @org = Org.new({
      :org_id => 12345
      })
  end

  describe "#new" do
    it "takes one parameter and returns an Org object" do
      @org.should be_an_instance_of Org
    end
  end
  
  describe "#org_id" do
    it "returns the correct org_id" do
      @org.org_id.should eql 12345
    end
  end
  
  describe "#existsorgExisting" do
    fixtures :orgs
    it "returns true since the queried org exists" do
      exists = Org.exists_org "12345"
      exists.should eql true
    end
  end

  describe "#existsorgNonExisting" do
    fixtures :orgs
    it "returns false since the queried org does not exists" do
      exists = Org.exists_org "1234567"
      exists.should eql false
    end
  end
  
  describe "#addOrgExisting" do
    fixtures :orgs
    it "fails to add a new org since it already exists" do
      exists = Org.exists_org "12345"
      exists.should eql true
      options = {:org_id => '12345'}
      Org.add_org options
      result = Org.where(:org_id => '12345')
      result.size.should eql 1
    end
  end
  
  describe "#addOrgNonExisting" do
    fixtures :orgs
    it "adds a new org" do
      exists = Org.exists_org "123456"
      exists.should eql false
      options = {:org_id => '123456'}
      Org.add_org options
      exists = Org.exists_org "123456"
      exists.should eql true
    end
  end
  
  describe "#getOrgbySalesforceidNonExistant" do
    fixtures :orgs
    it "fails to get an org since it does not exists" do
      result = Org.get_org_by_sfid '123456'
      result.should eql nil
    end
  end
  
  describe "#getOrgbySalesforceidExistant" do
    fixtures :orgs
    it "retrieves an org" do
      result = Org.get_org_by_sfid '12345'
      result.should be_an_instance_of Org
    end
  end
  
  describe "#test Syncronize" do
    pending "Need to create the tests for syncronize"
  end
end
