class TeamsController < ApplicationController
  # GET /teams
  # GET /teams.xml
  def index
    @teams = Team.includes(:finals, :qualifications).order(:fll_number)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teams }
    end
  end


  
  # GET /teams/1
  # GET /teams/1.xml
  def show
    @team = Team.find(params[:id])
    
    @qualifications = @team.qualifications.order(:match_number)
    @finals = @team.finals.order(:match_number)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team }
    end
  end

  # GET /teams/new
  # GET /teams/new.xml
  def new
    @team = Team.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team }
    end
  end

  # GET /teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /teams
  # POST /teams.xml
  def create
    @team = Team.new(params[:team])

    respond_to do |format|
      if @team.save
        flash[:notice] = 'Team was successfully created.'
        format.html { redirect_to(@team) }
        format.xml  { render :xml => @team, :status => :created, :location => @team }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /teams/1
  # PUT /teams/1.xml
  def update
    @team = Team.find(params[:id])

    respond_to do |format|
      if @team.update_attributes(params[:team])
        flash[:notice] = 'Team was successfully updated.'
        format.html { redirect_to(@team) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.xml
  def destroy
    @team = Team.find(params[:id])
    @team.destroy

    respond_to do |format|
      format.html { redirect_to(teams_url) }
      format.xml  { head :ok }
    end
  end

  def standings
    @teams = Team.includes(:qualifications).sort {|a,b| b.average_qual_score <=> a.average_qual_score}
    respond_to do |format|
      format.html
      format.xml { render :xml => @teams }
    end
  end
  
  def results
    
    #get all the teams
    @teams=Team.includes(:robot_scores, :project_scores, :corevalue_scores)
    
    #sort by qualification score, highest first, and rank them
    @teams.sort! {|a,b| b.average_qual_score <=> a.average_qual_score}
    @teams.each_with_index do |team, index|
      team.performance_rank = index + 1
    end
    
    # Calculate robot ranking score (robot presentation score + ranking)
    @teams.each do |team|
      team.total_score = (team.robot_scores_total / 2) + (team.performance_rank / 2)
    end
    
    #rank robot scores
    @teams.sort! {|a,b| b.total_score <=> a.total_score }
    @teams.each_with_index do |team, index|
      team.total_rank = index + 1
    end
    
    #sort project scores and rank them, highest first
    @teams = @teams.sort {|a,b| b.project_scores_total <=> a.project_scores_total }
    @teams.each_with_index do |team, index|
      team.project_rank = index + 1
    end
    
    #sort core values scores and rank them, highest first
    @teams.sort! {|a,b| b.corevalue_scores_total <=> a.corevalue_scores_total }
    @teams.each_with_index do |team, index|
      team.corevalue_rank = index + 1
    end
    
    #calculate champion score
    @teams.each do |team|
      team.champion_score = team.total_rank + team.project_rank + team.corevalue_rank
    end
    
    #sort champion scores and rank them, LOWEST first
    @teams.sort! {|a,b| a.champion_score <=> b.champion_score }
    @teams.each_with_index do |team, index|
      team.champion_rank = index + 1
    end
    
    #finally sort by team number
    @teams.sort! {|a,b| a.fll_number <=> b.fll_number}
    
  end

end
