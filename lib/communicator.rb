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
            Juggernaut.publish("subscribe", data)	
          when :unsubscribe
            Juggernaut.publish("unsubscribe", data)	
        end
      end
    end
  end
end
