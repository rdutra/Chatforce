class ChannelController < ApplicationController


  def create_channel
    receiver_id = params[:receiver_id]
    
    @channel    = Channel.get_channel(:receiver_id => receiver_id, :sender_id => current_user.id)
    Channel.find_or_create_by_receiver_id_and_sender_id(:receiver_id => current_user.id, :sender_id => receiver_id)               #Current user is receiver
    render :text =>  @channel.channel_id
  end
  
  def show_channel  
    @current_channel   = Channel.find_by_channel_id(params['id'])
    @receiver_channel =  Channel.find_by_receiver_id_and_sender_id(current_user.id, @current_channel.receiver_id)
    return redirect_to root_path, :flash => {:error => 'Invalid url'} unless @current_channel
  end
end
