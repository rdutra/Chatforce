require 'users'
class AuthorizationController < ApplicationController

  def create
    ENV['sfdc_token'] = request.env['omniauth.auth']['credentials']['token']
    ENV['sfdc_instance_url'] = request.env['omniauth.auth']['instance_url']
    sfuser = Users.getMe
    if not Buddy.exists_buddy sfuser[:id]
      new_user = Buddy.new({
        :name             => sfuser[:name],
        :nickname         => '',
        :status           => "Available",
        :salesforce_id    => sfuser[:id],
        :small_photo_url  => sfuser[:smallPhotoUrl]
      })
      new_user.save
    else
      new_user = Buddy.get_buddy_by_Sfid sfuser[:id]
    end
    if new_user
      #new_user.set_status new_user.id "Available"
    end
    redirect_to :controller => 'buddies', :action => 'index'
  end
  
  def fail
    render :text =>  request.env["omniauth.auth"].to_yaml
  end
end
