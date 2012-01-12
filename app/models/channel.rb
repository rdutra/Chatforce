require 'ruby-debug' ; Debugger.start
class Channel < ActiveRecord::Base
  belongs_to :sender,   :class_name => 'Buddy', :foreign_key => 'sender_id'
  belongs_to :receiver, :class_name => 'Buddy', :foreign_key => 'receiver_id'
  
  def self.get_channel sender_id, receiver_id
    req_channel = Channel.where(:sender_id => sender_id, :receiver_id => receiver_id)[0]
    return req_channel
  end
  
  def self.create_channel options
    new_channel = Channel.new(options)
    new_channel.key = ActiveSupport::SecureRandom.hex(15)
    new_channel.save
    return new_channel
  end
  
  def self.delete_channel key
    Channel.delete(key)
  end
  
  def self.get_ring_communication user_id, org_id
    req_org = Channel.where(:key => org_id)[0]
    if req_org.nil?
      options = {:sender_id => user_id, :receiver_id => user_id}
      req_org = Channel.new(options)
      req_org.key = org_id
      req_org.save
    end
    return req_org  
  end
end
