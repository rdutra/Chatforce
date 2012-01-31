require 'security'
class SettingsController < ApplicationController
  #this controller has been deprecated, methods here are split between application controller (save) and buddy controller (index)
  def index
    @session = Session.get_session_by_id cookies.signed[:chgo_user_session][0]
    @skins = Skin.get_skins
    @settings = Setting.get_settings @session["buddy_id"]
    unless @settings.nil?
      history = @settings['history']
      @checkvalue = ''
      if history == 1 
        @checkvalue = 'on'
      end
      puts 'data'
      puts @checkvalue
      @skin = @settings['skin']
    end
  end
  
  def save_setting
    @session = Session.get_session_by_id cookies.signed[:chgo_user_session][0]
    if params["check_id"] == 'on'
      ahistory = 1
    else  
      ahistory = 0
    end
    options = {
      :history      => ahistory,
      :skin         => params["select_skin"],
      :buddy_id     => @session["buddy_id"]
    }
    Setting.save_settings(options)
    redirect_to :controller => 'buddies', :action => 'index'
  end
  
end
