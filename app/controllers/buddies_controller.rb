class BuddiesController < ApplicationController
  # GET /buddies
  # GET /buddies.json
  def index
    @buddies = Buddy.all

    respond_to do |format|
      format.html # index.haml
      format.json { render json: @buddies }
    end
  end

end
