require 'ruby-debug' ; Debugger.start
class Channel < ActiveRecord::Base
  has_many :connection
  has_many :buddy, :through => :connection
  
  def self.get_channel_by_id channel_id
    req_channel = Channel.find(channel_id)
    return req_channel
  end
  
  def self.create_channel mod
    new_channel = Channel.new
    new_channel.key = ActiveSupport::SecureRandom.hex(15)
    new_channel.mod = mod
    new_channel.save
    return new_channel
  end
  
  def self.delete_channel_by_id channel_id
    Channel.delete(channel_id)
  end
  
  def self.get_ring_communication buddy_id, org_id
    buddy = Buddy.find(buddy_id)
    org = nil
    unless buddy.nil?
      org = Channel.where(:key => org_id)[0]
      if org.nil?
        org = Channel.create_channel "org"
        org.key = org_id
        org.save
      end
    end  
    return org  
  end
end
