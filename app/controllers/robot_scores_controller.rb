class RobotScoresController < ApplicationController

  respond_to :html, :xml, :json
  
  def new
    
    @team = Team.find params[:team_id]
    @robotscore = RobotScore.new
    respond_with(@team, @robotscore)
    
  end
  
  def index
    @team  = Team.find params[:team_id]
    respond_with(@team.robot_scores)
  end
  
  def show
    @team  = Team.find params[:team_id]
    respond_with(@team.robot_scores.find(params[:id]))
  end
  
  def create
    @team = Team.find(params[:team_id])
    @robotscore = @team.robot_scores.build(params[:robot_score])
    flash[:notice] = "Robot score created" if @robotscore.save
    
    respond_with(@team, @robotscore, :location => @team)
  end 
  
  def edit
    @team = Team.find params[:team_id]
    @robotscore = @team.robot_scores.find(params[:id])
    respond_with(@team, @robotscore)
  end
  
  def update
    team = Team.find(params[:team_id])
    robot_score = team.robot_scores.find(params[:id]).update_attributes(params[:robot_score])
    flash[:notice] = "Robot score updated" if robot_score
    respond_with(team, robot_score, :location => team)
  end 
end
