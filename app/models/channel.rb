class Channel < ActiveRecord::Base
  set_primary_key :channel_id
  belongs_to :sender,   :class_name => 'User', :foreign_key => 'sender_id'
  belongs_to :receiver, :class_name => 'User', :foreign_key => 'receiver_id'
  
  has_many :messages
  
  private
  def set_channel_id
    self.channel_id = ActiveSupport::SecureRandom.hex(15)
  end
end
