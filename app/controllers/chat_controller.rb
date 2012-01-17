require "juggernaut"
require "communicator"
require 'ruby-debug' ; Debugger.start
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
    session = Session.get_session_by_id cookies.signed[:chgo_user_session][0]
    @user_name = session[:name]
  end

  def create_channel
      org_channel = params[:channel]
      sender = params[:sender]
      receiver = params[:receiver]
      new_channel = Channel.create_channel "chat"
      Connection.connect_buddy sender, new_channel[:id]
      Communicator.send_message org_channel, sender, receiver, new_channel[:id]
      render :text => new_channel["key"]
  end
  
  def connect_channel
    channel = params[:channel]
    sender = params[:sender]
    receiver = params[:receiver]
    channel_chat = Channel.get_channel_by_id channel
    Connection.connect_buddy sender, channel
    render :text => channel_chat[:key]
  end
  
  def get_data 
    session = Session.get_session_by_id cookies.signed[:chgo_user_session][0]
    org_id = session["token"].split('!')[0]
        
    data = {
      :org_channel => org_id,
      :buddy_id => session[:buddy_id]
    }
    render :json => data.to_json
    
  end
  
end
