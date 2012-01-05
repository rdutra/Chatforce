require "juggernaut"
class ChatController < ApplicationController
  def send_message
    @messg = params[:msg_body]
    @sender = "user"
    Juggernaut.publish(select_channel("user"), parse_chat_message(params[:msg_body], "user"))	
    render :nothing => true
	end

	def parse_chat_message(msg, user)
    return "#{user}: #{msg}"
	end

	def select_channel(receiver)
    puts "#{receiver}"
    return receiver
	end
  
  def single_chat
    
  end
  
end
