class RobotScoresController < ApplicationController
  def new
    
    @team = Team.find params[:team_id]
    @robotscore = RobotScore.new

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
    @robotscore = @team.robot_score
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team }
    end
  end
  
  def update
    @team = Team.find params[:team_id]
    @team.robot_score.update_attributes(params[:robot_score])
    
    respond_to do |format|
      if @team.save
        flash[:notice] = 'Robot score updated.'
        format.html { redirect_to :controller => "teams" }
        format.xml  { render :xml => team, :status => :created, :location => team }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => team.errors, :status => :unprocessable_entity }
      end
    end
  end 
end
