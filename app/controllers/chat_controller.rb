require "juggernaut"
require "communicator"
class ChatController < ApplicationController
  def send_message
    message = params[:message]
    channel = params[:channel]
    sender  = params[:sender]
    receiver = params[:receiver]
    buddy = Buddy.get_buddy_by_id sender
    
    Communicator.send_message channel, buddy[:name], receiver, message
    render :nothing => true
	end
 
  def single_chat
    @channel = params[:channel]
  end

  def create_channel
      sender = params[:sender]
      receiver = params[:receiver]
      channel = params[:channel]
            
      options = {
        :sender_id => sender,
        :receiver_id => receiver
      }
      new_channel = Channel.create_channel options
      Communicator.send_message channel, sender, receiver, "invite"
      render :text => new_channel["key"]
  end
  
  def test 
    Communicator.send_message "Testeo", cookies[:chgo_org_key]
  end
  
end
