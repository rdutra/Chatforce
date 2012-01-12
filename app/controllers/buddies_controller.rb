require 'security'
require 'ruby-debug' ; Debugger.start
class BuddiesController < ApplicationController
  # GET /buddies
  # GET /buddies.json
  def index
    
    @session = Session.get_session_by_buddy_id cookies['chgo_user_id']
    org_id = @session["token"].split('!')[0]
    org = Org.get_org_by_sfid(org_id)
    @buddies = Buddy.get_buddies_by_org org["id"]
   
    
    @org_channel = Channel.get_ring_communication @session["buddy_id"], org_id
    cookies[:chgo_org_key] = @org_channel['key']
    
    
  end

end
