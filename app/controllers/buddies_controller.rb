require 'security'
class BuddiesController < ApplicationController
  # GET /buddies
  # GET /buddies.json
  def index
    
    @user_id = Security.decrypt ENV[:uid]
    @buddies = Buddy.get_all
    org_id = ENV['sfdc_token'].split('!')[0]
    @org_channel = Channel.get_ring_communication @user_id, org_id
    cookies[:chgo_org_key] = @org_channel['key']
    
    
  end

end
