require 'security'
require 'communicator'
require 'ruby-debug' ; Debugger.start
class BuddiesController < ApplicationController
  
  def index
    
    @session = Session.get_session_by_id cookies.signed[:chgo_user_session][0]
    org_id = @session["token"].split('!')[0]
    Org.synchronize_simple org_id, @session["instance_url"], @session["token"]  
    org = Org.get_org_by_sfid(org_id)
    @buddies = Buddy.get_buddies_by_org org["id"]
    @org_channel = Channel.get_ring_communication @session["buddy_id"], org_id
    Connection.connect_buddy @session["buddy_id"], @org_channel[:id]
    @user_name = @session[:name]

    # change status
    message = {:code => "status", :message => "Online"}
    Communicator.send_message org_id, @session["buddy_id"], 0, message
    #Communicator.subscribe
       
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

end
