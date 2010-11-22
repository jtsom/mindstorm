class RobotScoresController < ApplicationController

  respond_to :html
  
  def new
    
    @team = Team.find params[:team_id]
    @robotscore = RobotScore.new
    respond_with(@team, @robotscore)
    
  end
  
  def create
    team = Team.find params[:team_id]
    team.create_robot_score(params[:robot_score])
    
    respond_to do |format|
      if team.save
        flash[:notice] = 'Technical score entered.'
        format.html { redirect_to :controller => "teams" }
        format.xml  { render :xml => team, :status => :created, :location => team }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => team.errors, :status => :unprocessable_entity }
      end
    end
  end 
  
  def edit
    @team = Team.find params[:team_id]
    @robotscore = @team.robot_scores.find(params[:id])
    respond_with(@team, @robotscore)
  end
  
  def update
    @team = Team.find params[:team_id]
    @team.robot_scores.find(params[:id]).update_attributes(params[:robot_score])
    
    respond_to do |format|
      if @team.save
        flash[:notice] = 'Robot score updated.'
        format.html { redirect_to @team }
        format.xml  { render :xml => team, :status => :created, :location => team }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => team.errors, :status => :unprocessable_entity }
      end
    end
  end 
end
