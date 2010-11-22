class ProjectScoresController < ApplicationController
  def new
    
    @team = Team.find params[:team_id]
    @projectscore = ProjectScore.new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team }
    end
  end
  
  def create
    team = Team.find params[:team_id]
    team.create_project_score(params[:project_score])
    
    respond_to do |format|
      if team.save
        flash[:notice] = 'Project score entered.'
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
    @projectscore = @team.project_score
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team }
    end
  end
  
  def update
    @team = Team.find params[:team_id]
    @team.project_score.update_attributes(params[:project_score])
    
    respond_to do |format|
      if @team.save
        flash[:notice] = 'Project score updated.'
        format.html { redirect_to :controller => "teams" }
        format.xml  { render :xml => team, :status => :created, :location => team }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => team.errors, :status => :unprocessable_entity }
      end
    end
  end
end
