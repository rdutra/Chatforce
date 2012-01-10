require "juggernaut"
require "communicator"
class ChatController < ApplicationController
  def send_message
    messg = params[:msg_body]
    sender = params[:channel]
    Communicator.send_message messg, sender
    render :nothing => true
	end
 
  def single_chat
    @channel = params[:channel]
  end
  
  def test 
    Communicator.send_message "Testeo", cookies[:chgo_org_key]
  end
  
end
