require 'spec_helper'

describe Channel do
  before :each do
    @channel = Channel.new({
      :key     => 'key',
      :mod     => 'mod'
      })
  end

  describe "#new" do
    it "takes two parameters and returns a Channel object" do
      @channel.should be_an_instance_of Channel
    end
  end

  describe "#key" do
    it "returns the correct key" do
      @channel.key.should eql 'key'
    end
  end
  
  describe "#mod" do
    it "returns the correct mod" do
      @channel.mod.should eql 'mod'
    end
  end

end