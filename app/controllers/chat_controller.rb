require "juggernaut"
require "communicator"
#require 'ruby-debug' ; Debugger.start
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
  
  def invite_return_channel
    channel = params[:channel]
    sender  = params[:sender]
    receiver = params[:receiver]
       
    new_channel = Channel.create_channel "chat"
    Connection.connect_buddy sender, new_channel[:id]  
    message = {:code => "invite", :message => new_channel[:key]}
    
    Communicator.send_message channel, sender, receiver, message
    render :text => new_channel[:key]
  end
  
  def re_invite
    channel = params[:channel]
    receiver = params[:sender]
    sender = params[:receiver]
       
    new_channel = Channel.create_channel "chat"
    Connection.connect_buddy sender, new_channel[:id]   
    message = {:code => "invite", :message => new_channel[:key]}
    
    Communicator.send_message channel, sender, receiver, message
    render :text => new_channel[:key]
  end
  
  def connect_buddy
    channel = params[:channel]
    sender  = params[:sender]  
    channel_conn = Channel.where(:key => params[:channel_conn])[0]
    receiver = params[:receiver]
    
    Connection.connect_buddy sender, channel_conn[:id]
    message = {:code => "invite", :message => channel_conn[:key]}
    
    Communicator.send_message channel, sender, receiver, message
    render :nothing => true
  
  end
  
  def accept
    channel = params[:channel]
    sender  = params[:sender]
    receiver = params[:receiver]
    channel_conn = params[:channel_conn]
    real_channel = Channel.get_channel_by_key channel_conn
    
    Connection.connect_buddy sender, real_channel.id
    
    message = {:code => "accept", :message => "accept", :channel_conn => channel_conn}
    Communicator.send_message channel, sender, receiver, message
    render :text => channel_conn
  end

  def write
    message = params[:message]
    channel = params[:channel]
    sender = params[:sender]
    
    buddy = Buddy.get_buddy_by_id sender
    message = {:code => "write", :message => message, :sender => sender, :senderName => buddy[:name], :date => DateTime.now().to_s(:toShort)}
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
  
  def connect_channel_by_key
    channel_key = params[:channel]
    sender = params[:sender]
    channel_chat = Channel.get_channel_by_key channel_key
    Connection.connect_buddy sender, channel_chat[:id]
    render :nothing => true
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
    
    token = Session.get_session_by_id(cookies.signed[:chgo_user_session][0]).token
    unless buddy[:small_photo_url].nil?
      pic = buddy[:small_photo_url] + '?oauth_token=' + token
    else
      pic = ''
    end
    
    com_message = {:code => "write",
					:message => message,
					:sender => sender, 
					:senderName => buddy[:name], 
					:date => DateTime.now().to_s(:toShort),
					:pic => pic,
					:status => buddy[:status]
					}
    data = {:buddy_id => buddy[:id], :channel => channel, :message => message}
    Buffer.add_to_buffer data
    Communicator.send_message channel, sender, nil, com_message
    render :text => "#{sender} : #{message}"
  end
  
  def get_buffer
    channel = params[:channel]
    buffers = Buffer.get_from_buffer_by_channel channel
    ret = []
    buffers.each do |buff|
      ret.push({ :message => { 
                  :message => buff.message,
                  :sender => buff.buddy_id,
                  :senderName => buff.buddy[:name],
                  :date => buff.created_at.to_s(:toShort)
                },
                :channel => channel
      })
    end
    render :json => ret.to_json
  end
  
  def set_status
    status = params[:message]
    channel = params[:channel]
    sender = params[:sender]
    
    message = {:code => "status", :message => status}
    Communicator.send_message channel, sender, 0, message
    Buddy.set_status sender, status
    render :nothing => true
  end

  def get_channel_and_buffer
	
    channel = params[:channel]
    sender = params[:sender]
    
    buddy = Buddy.get_buddy_by_id sender
    
    buffer_to_show = Buffer.get_buffer_by_channel_and_buddy sender channel
    
    returned = Array.new(2)
    
    puts buffer_to_show.inspect
    
    returned[0] =  buddy
    returned[1] =  buffer_to_show
    
    render :json => returned.to_json
  end
  

  def send_notification
    
    org_channel = params[:org_channel]
    sender  = params[:sender]
    receiver = params[:receiver]
    message = params[:message]
    
    buddy = Buddy.get_buddy_by_id sender
    puts buddy.inspect
    token = Session.get_session_by_id(cookies.signed[:chgo_user_session][0]).token
    unless buddy[:small_photo_url].nil?
      pic = buddy[:small_photo_url] + '?oauth_token=' + token
    else
      pic = ''
    end
     
    message = {:code => "notify",
				:message => message,
				:sender_id => sender,
				:receiver_id => receiver, 
				:senderName => buddy[:name],
				:pic => pic,
				:status => buddy[:status]}   
    Communicator.send_message org_channel, sender, receiver, message
    
    render :nothing => true
  end

  def prediction
    pred = params[:message]
    channel = params[:channel]
    sender = params[:sender]
    
    buddy = Buddy.get_buddy_by_id sender
    
    message = {:code => "prediction", :prediction => pred, :senderName => buddy[:name]}
    Communicator.send_message channel, sender, nil, message
    render :nothing => true
  end
  
  def get_buddy_info
  
    buddyReciver = Buddy.get_buddy_by_id params[:buddy]
    
    token = Session.get_session_by_id(cookies.signed[:chgo_user_session][0]).token
    unless buddyReciver[:small_photo_url].nil?
      pic = buddyReciver[:small_photo_url] + '?oauth_token=' + token
    else
      pic = ''
    end
    response =  {
      :name => buddyReciver[:name],
      :pic => pic,
      :status => buddyReciver[:status]
    }
    render :json => response.to_json
  end
  
end
