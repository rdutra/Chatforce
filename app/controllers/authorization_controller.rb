require 'users'
require 'security'
require 'ruby-debug' ; Debugger.start
class AuthorizationController < ApplicationController

  def create
    user_session = cookies.signed[:chgo_user_session]
    if user_session.nil?
      salesforce_token = request.env['omniauth.auth']['credentials']['token']
      salesforce_instance = request.env['omniauth.auth']['instance_url']
      if Org.has_installed_package salesforce_instance, salesforce_token
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
          #this syncronize needs to either load on the first user that starts the app only
          Org.synchronize org_id, salesforce_instance, salesforce_token
        end
      else
        render :text => 'Ask your admin to install Timba go to start chatting'
        return
      end
        
      
      #exist session?
      buddy_session = Session.get_session_by_buddy_id buddy["id"]
      if buddy_session.nil?
        options = {
          :buddy_id => buddy["id"],
          :expires_at => Time.now + 30.minutes,
          :token => salesforce_token,
          :instance_url => salesforce_instance,
          :name => buddy[:name]
        }
        buddy_session = Session.create_session options
        #hash = create_session_cookie buddy_session["id"]
      else
        #refresh session
        if buddy_session['expires_at'] >= buddy_session["created_at"]
          options = {
            :buddy_id => buddy["id"],
            :expires_at => Time.now + 30.minutes,
            :token => salesforce_token,
            :instance_url => salesforce_instance,
            :name => buddy[:name]
          }
        buddy_session = Session.updatewhole buddy_session, options
        end
      end  
      hash = create_session_cookie buddy_session["id"]
      Session.refresh buddy_session["id"], hash
     
    else
      buddy = authenticate_with_salt(cookies.signed[:chgo_user_session][0],cookies.signed[:chgo_user_session][1] )
      unless buddy.nil?
        hash = create_session_cookie cookies.signed[:chgo_user_session][0]
        Session.refresh cookies.signed[:chgo_user_session][0], hash
      else
        cookies.delete(:chgo_user_session)
      end
    end
    
    Buddy.set_status buddy[:id], "Available"
    redirect_to :controller => 'buddies', :action => 'index'
  end
  
  def create_session_cookie session_id
    new_hash = ActiveSupport::SecureRandom.base64(32)
    cookies.permanent.signed[:chgo_user_session] = [session_id, new_hash]
    return new_hash
  end
  
  def authenticate_with_salt(id, cookie_salt)
    session = Session.get_session_by_id(id)
    return nil if session.nil?
    return session if session.salt == cookie_salt
  end
  
  def fail
    render :text =>  request.env["omniauth.auth"].to_yaml
  end
end
