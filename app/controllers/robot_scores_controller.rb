class RobotScoresController < ApplicationController

  before_filter :authenticate

 respond_to :html, :xml, :json
  
  def new
    
    @team = @current_competition.teams.find params[:team_id]
    @robotscore = RobotScore.new
    respond_with(@team, @robotscore)
    
  end
  
  def index
    @team  = @current_competition.teams.find params[:team_id]
    respond_with(@team.robot_scores)
  end
  
  def show
    @team  = @current_competition.teams.find params[:team_id]
    respond_with(@team.robot_scores.find(params[:id]))
  end
  
  def create
    @team = @current_competition.teams.find(params[:team_id])
    @robotscore = @team.robot_scores.build(params[:robot_score])
    flash[:notice] = "Robot score created" if @robotscore.save
    
    respond_with(@team, @robotscore, :location => @team)
  end 
  
  def edit
    @team = @current_competition.teams.find params[:team_id]
    @robotscore = @team.robot_scores.find(params[:id])
    respond_with(@team, @robotscore)
  end
  
  def update
    team = @current_competition.teams.find(params[:team_id])
    robot_score = team.robot_scores.find(params[:id]).update_attributes(params[:robot_score])
    flash[:notice] = "Robot score updated" if robot_score
    respond_with(team, robot_score, :location => team)
  end 
  
  def destroy
    @team = @current_competition.teams.find(params[:team_id])
    score = @team.robot_scores.find(params[:id])
    score.destroy
    flash[:notice] = "Robot Score Entry team #{@team.fll_number} deleted."
    redirect_to @team
  end
  
private
    def authenticate
      if current_competition == nil
        redirect_to root_url
      end
    end
end
