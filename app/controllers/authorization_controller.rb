require 'users'
require 'security'
#require 'ruby-debug' ; Debugger.start
class AuthorizationController < ApplicationController

  def create
    ENV['sfdc_token'] = request.env['omniauth.auth']['credentials']['token']
    ENV['sfdc_instance_url'] = request.env['omniauth.auth']['instance_url']

    
    sfuser = Users.getMe
    
    if session[:uid].nil?
      session[:uid] = Security.encrypt sfuser["id"]
    end

    orgid = ENV['sfdc_token'].split('!')[0]
    if not Org.exists_org orgid
      options = {
        :org_id => orgid
      }
      currentOrg = Org.add_org options
    else
      currentOrg = Org.getOrgBySfId orgid    
    end

    unless Buddy.exists_buddy sfuser["id"]
      options = {
        :name             => sfuser["name"],
        :nickname         => '',
        :status           => "Available",
        :salesforce_id    => sfuser["id"],
        :small_photo_url  => sfuser["smallPhotoUrl"],
        :org_id           => currentOrg["id"]
      }
      Buddy.add_buddy options
    else
      puts 'round 2'
      puts sfuser["id"]
      new_user = Buddy.get_buddy_by_Sfid sfuser["id"]
      Org.synchronize orgid
    end
    if new_user
      Buddy.set_status sfuser["id"], "Available"
    end
    redirect_to :controller => 'buddies', :action => 'index'
  end
  
  def fail
    render :text =>  request.env["omniauth.auth"].to_yaml
  end
end
