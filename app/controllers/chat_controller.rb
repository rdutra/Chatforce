require "juggernaut"
require "communicator"
class ChatController < ApplicationController
  def send_message
    message = params[:message]
    channel = params[:channel]
    sender  = params[:sender]
    receiver = params[:receiver]
    
    Communicator.send_message channel, sender, receiver, message
    render :nothing => true
	end
 
  def single_chat
    @channel = params[:channel]
  end
  
  def test 
    Communicator.send_message "Testeo", cookies[:chgo_org_key]
  end
  
end
