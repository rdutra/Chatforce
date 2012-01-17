require 'spec_helper'

describe Buddy do
  before :each do
    @buddy = Buddy.new({
      :name => "Test Buddy", 
      :nickname => "Test Nickname", 
      :status =>"Test Status", 
      :salesforce_id => "Test Salesforce ID", 
      :small_photo_url => "Test small photo", 
      :org_id =>"test org id"
      })
  end
  
  describe "#new" do
    it "takes six parameters and returns a Buddy object" do
      @buddy.should be_an_instance_of Buddy
    end
  end
  
end
