require 'rubygems'
require 'encryptor'

class Communicator
  def self.send_message channel, sender, receiver, message
    data = {
      :channel => channel,
      :sender => sender,
      :receiver => receiver,
      :message => message
    }
    Juggernaut.publish(channel, data)	
	end
end
