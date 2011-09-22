class ProjectScoresController < ApplicationController
  
  respond_to :html, :xml, :json
  
  def new   
    @team = Team.find params[:team_id]
    @projectscore = ProjectScore.new
    respond_with(@team, @projectscore)
  end
  
  def index
    @team  = Team.find params[:team_id]
    respond_with(@team.project_scores)
  end
  
  def show
    @team  = Team.find params[:team_id]
    respond_with(@team.project_scores.find(params[:id]))
  end
  
  def create
    @team = Team.find(params[:team_id])
    @projectscore = @team.project_scores.build(params[:project_score])
    flash[:notice] = "Project score created" if @projectscore.save
    
    respond_with(@team, @projectscore, :location => @team)
  end
  
  def edit
    @team = Team.find(params[:team_id])
    @projectscore = @team.project_scores.find(params[:id])
    
    respond_with(@team, @projectscore)
  end
  
  def update
    @team = Team.find(params[:team_id])
    @project_score = @team.project_scores.find(params[:id]).update_attributes(params[:project_score])
    flash[:notice] = "Project score updated" if @project_score
    respond_with(@team, @project_score, :location => @team)
  end
end
