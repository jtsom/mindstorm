class CompetitionsController < ApplicationController
  http_basic_authenticate_with :name => "team467", :password => "dtb", :except => :index
  # GET /competitions
  # GET /competitions.json
  def index
    @competitions = Competition.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @competitions }
    end
  end

def show

end

  # GET /competitions/new
  # GET /competitions/new.json
  def new
    @competition = Competition.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @competition }
    end
  end

  # GET /competitions/1/edit
  def edit
    @competition = Competition.find(params[:id])
  end

  # POST /competitions
  # POST /competitions.json
  def create
    @competition = Competition.new(comp_params)

    respond_to do |format|
      if @competition.save
        format.html { redirect_to competitions_url, notice: 'Competition was successfully created.' }
        format.json { render json: @competition, status: :created, location: @competition }
      else
        format.html { render action: "new" }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /competitions/1
  # PUT /competitions/1.json
  def update
    @competition = Competition.find(params[:id])

    respond_to do |format|
      if @competition.update_attributes(comp_params)
        format.html { redirect_to competitions_url, notice: 'Competition was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /competitions/1
  # DELETE /competitions/1.json
  def destroy
    @competition = Competition.find(params[:id])
    @competition.destroy

    respond_to do |format|
      format.html { redirect_to competitions_url }
      format.json { head :ok }
    end
  end

  private

  def comp_params
    params.require(:competition).permit(:name, :email, :password, :from_email, :full_name ,:contact_name, :send_email, :judge_lanes)
  end
end
