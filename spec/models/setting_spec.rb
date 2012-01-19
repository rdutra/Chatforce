require 'spec_helper'

describe Setting do
  before :each do
    @setting = Setting.new({
      :skin => 1, 
      :history => 1, 
      :buddy_id => 1
      })
  end
  
  describe "#new" do
    it "takes three parameters and returns a Settings object" do
      @setting.should be_an_instance_of Setting
    end
  end
  
  describe "#skin" do
    it "returns the correct skin id" do
      @setting.skin.should eql 1
    end
  end
  
  describe "#history" do
    it "returns the correct history setting" do
      @setting.history.should eql 1
    end
  end
  
  describe "#buddy_id" do
    it "returns the correct buddy id" do
      @setting.buddy_id.should eql 1
    end
  end
  
  describe "#existssetting" do
    fixtures :settings
    it "returns an existing setting" do
      exists = Setting.existsSetting 1
      exists.should eql true
    end
  end
  
  describe "#NotExistsSetting" do
    fixtures :settings
    it "returns nothing since this setting should not exist" do
      exists = Setting.existsSetting 3
      exists.should eql false
    end
  end
  
  describe "#savesettingUPDATE" do
    fixtures :settings
    it "saves a setting in the DB performs an update since the setting is already there" do
      exists = Setting.existsSetting 1
      exists.should eql true
      options = {
        :history      => 0,
        :skin         => 2,
        :buddy_id     => 1
      }
      Setting.save_settings options
      exists = Setting.existsSetting 1
      exists.should eql true
    end
  end
  
  describe "#savesettingsNEW" do
    fixtures :settings
    it "saves a setting in the DB performin an insert since the setting for this user is not there" do
      exists = Setting.existsSetting 3
      exists.should eql false
      options = {
        :history      => 0,
        :skin         => 2,
        :buddy_id     => 3
      }
      Setting.save_settings options
      exists = Setting.existsSetting 3
      exists.should eql true
    end
  end
  
  describe "#existssettingExisting" do
    fixtures :settings
    it "retrieves the setting for a particular user in this case the setting exists" do
      setting = Setting.get_settings 1
      setting.id.should eql 1
    end
  end
  
  describe "#existssettingNonexistent" do
    fixtures :settings
    it "retrieves nothing since the setting does not exists" do
      setting = Setting.get_settings 3
      settings.should eql []
    end
  end
end
