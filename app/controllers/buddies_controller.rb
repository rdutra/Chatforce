class BuddiesController < ApplicationController
  # GET /buddies
  # GET /buddies.json
  def index
    @buddies = Users.getAll
    @buddies = @buddies["records"]
  end

end
