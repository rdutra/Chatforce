require 'users'
require 'security'
#require 'ruby-debug' ; Debugger.start
class AuthorizationController < ApplicationController

  skip_before_filter :require_auth, :only => [:connect, :create]

  def connect
    user_session = cookies.signed[:chgo_user_session]
    if user_session.nil?
      redirect_to "/auth/forcedotcom"
    else
      redirect_to :action => "create"
    end  
  end
  
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
            :status           => "Online",
            :salesforce_id    => buddy_data["id"],
            :small_photo_url  => buddy_data["smallPhotoUrl"],
            :org_id           => current_org["id"]
          }
          buddy = Buddy.add_buddy options
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
      else
        #refresh session
        if buddy_session['expires_at'] <= Time.now
          hash = create_session_cookie buddy_session['id']
          options = {
            :buddy_id => buddy["id"],
            :expires_at => Time.now + 30.minutes,
            :token => salesforce_token,
            :instance_url => salesforce_instance,
            :name => buddy[:name],
            :salt => hash
          }
          buddy_session = Session.refresh buddy_session["id"], options
        end
      end
      hash = create_session_cookie buddy_session["id"]
      Session.refresh_salt buddy_session["id"], hash
    else
      buddy = authenticate_with_salt(cookies.signed[:chgo_user_session][0],cookies.signed[:chgo_user_session][1] )
      unless buddy.nil?
        hash = create_session_cookie cookies.signed[:chgo_user_session][0]
        Session.refresh_salt cookies.signed[:chgo_user_session][0], hash
      else
        cookies.delete(:chgo_user_session)
      end
    end
    
    unless buddy.nil?
      Buddy.set_status buddy[:id], "Online"
      redirect_to :controller => 'buddies', :action => 'index'
    else
      redirect_to "/index.html"
    end  
  end
  
  def create_session_cookie session_id
    new_hash = ActiveSupport::SecureRandom.base64(32)
    cookies.permanent.signed[:chgo_user_session] = [session_id, new_hash]
    return new_hash
  end
  
  def authenticate_with_salt(id, cookie_salt)
    session = Session.get_session_by_id(id)
    unless session.nil?
      if ((session.salt != cookie_salt) || (session['expires_at'] <= Time.now))
        session = nil
      end  
    end
    return session
  end
  
  def fail
    render :text =>  request.env["omniauth.auth"].to_yaml
  end
end
