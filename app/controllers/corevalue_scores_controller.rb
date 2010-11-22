class CorevalueScoresController < ApplicationController
  
  respond_to :html
  
  def new
    @team = Team.find params[:team_id]
    @corevalue_scores = CorevalueScore.new
  end
  
  def create
    @team = Team.find(params[:team_id])
    @corevalue_score = @team.corevalue_scores.build(params[:corevalue_score])
    flash[:notice] = "Core Values score created" if @corevalue_score.save
    
    respond_with(@team, @corevalue_score)
  end
  
  def edit
    
  end
  def update
    
  end
  
end