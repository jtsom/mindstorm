class CorevalueScoresController < ApplicationController
  
  respond_to :html, :xml, :json
  
  def new
    @team = current_competition.teams.find params[:team_id]
    @corevalue_score = CorevalueScore.new
    respond_with(@team, @corevalue_score)
  end
  
  def index
    @team  = current_competition.teams.find params[:team_id]
    respond_with(@team.corevalue_scores)
  end
  
  def show
    @team  = current_competition.teams.find params[:team_id]
    respond_with(@team.corevalue_scores.find(params[:id]))
  end
  
  def create
    @team = current_competition.teams.find(params[:team_id])
    @corevalue_score = @team.corevalue_scores.build(params[:corevalue_score])
    flash[:notice] = "Core Values score created" if @corevalue_score.save
    
    respond_with(@team, @corevalue_score, :location => @team)
  end
  
  def edit
    @team = current_competition.teams.find(params[:team_id])
    @corevalue_score = @team.corevalue_scores.find(params[:id])
    
    respond_with(@team, @corevalue_score)
  end
  
  def update
    team = current_competition.teams.find(params[:team_id])
    corevalue_score = team.corevalue_scores.find(params[:id]).update_attributes(params[:corevalue_score])
    flash[:notice] = "Core Values score updated" if corevalue_score
    respond_with(team, corevalue_score, :location => team)
  end
  
end