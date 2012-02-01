require 'rubygems'
require 'encryptor'

class Communicator

  class << self
    def send_message channel, sender, receiver, message
      data = {
        :channel => channel,
        :sender => sender,
        :receiver => receiver,
        :message => message
      }
      Juggernaut.publish(channel, data)	
    end
  
    def subscribe
      Juggernaut.subscribe do |event, data|
        case event
          when :subscribe
            puts data.inspect
          when :unsubscribe
            puts data.inspect
        end
      end
    end
  end
end
