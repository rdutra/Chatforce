require 'security'
require 'communicator'
require "juggernaut"
class BuddiesController < ApplicationController
  
  def index
    
    @session = Session.get_session_by_id cookies.signed[:chgo_user_session][0]
    org_id = @session["token"].split('!')[0]
    Org.synchronize_simple org_id, @session["instance_url"], @session["token"]  
    org = Org.get_org_by_sfid(org_id)
    @buddies = Buddy.get_buddies_by_org org["id"]
    @org_channel = Channel.get_ring_communication @session["buddy_id"], org_id
    Connection.connect_buddy @session["buddy_id"], @org_channel[:id]
    
    mychannels = Channel.joins(:connection).where(:connections => {:buddy_id => @session["buddy_id"]}, :mod =>  'chat')
    @myBuddiesMap = {}
    myBuddiesConnection = Connection.where 'channel_id IN (:mychannels) AND buddy_id <> :myBuddy', {:mychannels => mychannels, :myBuddy => @session["buddy_id"]}
    myBuddiesConnection.each do |con|
     @myBuddiesMap[con[:buddy_id]] = mychannels.find(con[:channel_id]).key
    end
    
    @buddy = Buddy.find @session["buddy_id"]
    @buddy.small_photo_url = (! @buddy.small_photo_url.nil?)? @buddy.small_photo_url + '?oauth_token=' + @session.token : ''
    @buddies.each do |buddy|
      buddy.small_photo_url = (! buddy.small_photo_url.nil?)? buddy.small_photo_url + '?oauth_token=' + @session.token : ''
    end
    # change status
    message = {:code => "status", :message => "Online"}
    Communicator.send_message org_id, @session["buddy_id"], 0, message
    
    # change legend
    message2 = {:code => "reload_nickname", :message => @buddy[:nickname]}
    Communicator.send_message org_id, @session["buddy_id"], 0, message2
    
    #settings
    @skins = Skin.get_skins
    @settings = Setting.get_settings @session["buddy_id"]
    unless @settings.nil?
      history = @settings['history']
      @checkvalue = ''
      if history == 1 
        @checkvalue = 'on'
      end
      @skin = @settings['skin']
    end

  end
  
  def get_buddy_by_id
    id_buddy = params[:buddy_id]
    buddy = Buddy.get_buddy_by_id id_buddy
    render :json => buddy.to_json
  end

end
