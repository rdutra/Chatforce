require 'users'
require 'security'
require 'ruby-debug' ; Debugger.start
class AuthorizationController < ApplicationController

  def create
    salesforce_token = request.env['omniauth.auth']['credentials']['token']
    salesforce_instance = request.env['omniauth.auth']['instance_url']
    
    buddy_data = Users.getMe salesforce_instance, salesforce_token
    buddy = Buddy.get_buddy_by_Sfid buddy_data["id"]
    
    #exist user?
    if buddy.nil?
      org_id = salesforce_token.split('!')[0]
      #exist org?
      current_org = Org.get_org_by_sfid org_id
      if current_org.nil?
        options = {
          :org_id => org_id
        }
        current_org = Org.add_org options
      end
      options = {
        :name             => buddy_data["name"],
        :nickname         => '',
        :status           => "Available",
        :salesforce_id    => buddy_data["id"],
        :small_photo_url  => buddy_data["smallPhotoUrl"],
        :org_id           => current_org["id"]
      }
      buddy = Buddy.add_buddy options
      Org.synchronize org_id, salesforce_instance, salesforce_token
    end
      
    cookies['chgo_user_id'] = buddy["id"]
    cookies['chgo_user_name'] = buddy["name"]
    
    #exist session?
    buddy_session = Session.get_session_by_buddy_id buddy["id"]
    if buddy_session.nil?
      options = {
        :buddy_id => buddy["id"],
        :expires_at => Time.now + 5.hours,
        :token => salesforce_token,
        :instance_url => salesforce_instance
      }
      buddy_session = Session.create_session options
    else
      #refresh session
      buddy_session = Session.refresh buddy_session["id"]
    end
   
    Buddy.set_status buddy_data["id"], "Available"
    redirect_to :controller => 'buddies', :action => 'index'
  end
  
  def fail
    render :text =>  request.env["omniauth.auth"].to_yaml
  end
end
