require 'security'
class BuddiesController < ApplicationController
  # GET /buddies
  # GET /buddies.json
  def index
    @user_id = Security.decrypt session[:uid]
    @buddies = Buddy.get_all
    
  end

end
