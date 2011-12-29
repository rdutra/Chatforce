class BuddiesController < ApplicationController
  # GET /buddies
  # GET /buddies.json
  def index
    @buddies = Buddy.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @buddies }
    end
  end

  # GET /buddies/1
  # GET /buddies/1.json
  def show
    @buddy = Buddy.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @buddy }
    end
  end

  # GET /buddies/new
  # GET /buddies/new.json
  def new
    @buddy = Buddy.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @buddy }
    end
  end

  # GET /buddies/1/edit
  def edit
    @buddy = Buddy.find(params[:id])
  end

  # POST /buddies
  # POST /buddies.json
  def create
    @buddy = Buddy.new(params[:buddy])

    respond_to do |format|
      if @buddy.save
        format.html { redirect_to @buddy, notice: 'Buddy was successfully created.' }
        format.json { render json: @buddy, status: :created, location: @buddy }
      else
        format.html { render action: "new" }
        format.json { render json: @buddy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /buddies/1
  # PUT /buddies/1.json
  def update
    @buddy = Buddy.find(params[:id])

    respond_to do |format|
      if @buddy.update_attributes(params[:buddy])
        format.html { redirect_to @buddy, notice: 'Buddy was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @buddy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /buddies/1
  # DELETE /buddies/1.json
  def destroy
    @buddy = Buddy.find(params[:id])
    @buddy.destroy

    respond_to do |format|
      format.html { redirect_to buddies_url }
      format.json { head :ok }
    end
  end
end
