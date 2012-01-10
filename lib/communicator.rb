require 'rubygems'
require 'encryptor'

class Communicator
  def self.send_message message, channel
    Juggernaut.publish(channel, "#{channel}: #{message}")	
	end
end
