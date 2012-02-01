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
 
  def invite
    channel = params[:channel]
    sender  = params[:sender]
    receiver = params[:receiver]
       
    new_channel = Channel.create_channel "chat"
    Connection.connect_buddy sender, new_channel[:id]   
    message = {:code => "invite", :message => new_channel[:key]}
    
    Communicator.send_message channel, sender, receiver, message
    render :nothing => true
  end
  
  def accept
    channel = params[:channel]
    sender  = params[:sender]
    receiver = params[:receiver]
    channel_conn = params[:channel_conn]
    
    Connection.connect_buddy receiver, channel_conn
    
    message = {:code => "accept", :message => "accept", :channel_conn => channel_conn}
    Communicator.send_message channel, sender, receiver, message
    render :nothing => true
  end
  
  def write
    message = params[:message]
    channel = params[:channel]
    sender = params[:sender]
    
    buddy = Buddy.get_buddy_by_id sender
    
    message = {:code => "write", :message => "#{buddy[:name]} : #{message}", :sender => sender}
    Communicator.send_message channel, sender, nil, message
    render :nothing => true
    
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
  
  def buffer
    message = params[:message]
    channel = params[:channel]
    sender = params[:sender]
    
    buddy = Buddy.get_buddy_by_id sender
    
    com_message = {:code => "write", :message => "#{buddy[:name]} : #{message}", :sender => sender}
    data = {:buddy_id => buddy[:id], :channel => channel, :message => "#{buddy[:name]} : #{message}"}
    Buffer.add_to_buffer data
    Communicator.send_message channel, sender, nil, com_message
    render :text => "#{sender} : #{message}"
  end
  
  def get_buffer
    channel = params[:channel]
    buffers = Buffer.get_from_buffer_by_channel channel
    render :json => buffers.to_json
  end
  
end
