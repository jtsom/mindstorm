class TeamsController < ApplicationController
  
 before_filter :authenticate
  
  # GET /teams
  # GET /teams.xml
  def index
    @teams = @current_competition.teams.includes(:finals, :qualifications).order(:fll_number)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teams.to_xml(:include => [:qualifications, :finals, :robot_scores, :project_scores, :corevalue_scores]) }
      #format.json { render :json => @teams.to_json(:include => [:qualifications, :finals,:robot_scores, :project_scores, :corevalue_scores]) }
      format.json { render :json => @teams }
    end
  end


  
  # GET /teams/1
  # GET /teams/1.xml
  def show
    @team = @current_competition.teams.find(params[:id])
    
    @qualifications = @team.qualifications.order(:match_number)
    @finals = @team.finals.order(:match_number)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team.to_xml(:include => [:qualifications, :finals,:robot_scores, :project_scores, :corevalue_scores]) }
      format.json { render :json => @team.to_json( :include => [:qualifications, :finals,:robot_scores, :project_scores, :corevalue_scores]) }
    end
  end

  # GET /teams/new
  # GET /teams/new.xml
  def new
    @team = @current_competition.teams.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team }
    end
  end

  # GET /teams/1/edit
  def edit
    @team = @current_competition.teams.find(params[:id])
  end

  # POST /teams
  # POST /teams.xml
  def create
    @team = @current_competition.teams.new(params[:team])

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
    @team = @current_competition.teams.find(params[:id])

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
    @team = @current_competition.teams.find(params[:id])
    @team.destroy

    respond_to do |format|
      format.html { redirect_to(teams_url) }
      format.xml  { head :ok }
    end
  end

  def upload
    uploaded = params[:csv_import][:file]
    raw = uploaded.read
    if raw.split("\r").length > 1
      data = raw.split("\r")
    else
      data = raw.split("\n")
    end
    
    Team.destroy_all(:competition_id => @current_competition.id)
    
    puts "size=" + data.length.to_s
    data.each { |line| 
      puts "line=" + line
      fields = line.split("\t")
      puts fields[0] + ' ' + fields[1]
      @current_competition.teams.create(:fll_number => fields[0], :team_name => fields[1], :school => fields[2], :town => fields[3], :coach => fields[4], :coach_email => fields[5], :asst_coach => fields[6], :asst_coach_email => fields[7], :state => fields[8])

    }
    
    flash[:notice] = 'Team list uploaded.'
    redirect_to :action => :index
  end
  
  def standings
    @teams = @current_competition.teams.includes(:qualifications).sort {|a,b| b.average_qual_score <=> a.average_qual_score}
    respond_to do |format|
      format.html
      format.xml { render :xml => @teams }
    end
  end
  
  def all_teams
    @teams=@current_competition.teams.includes(:robot_scores, :project_scores, :corevalue_scores).order(:fll_number)
  end
  
  def sendresults
    @team = @current_competition.teams.find(params[:id])
    
    @qualifications = @team.qualifications.order(:match_number)
    @finals = @team.finals.order(:match_number)
    
    TeamMailer.team_details_email(current_competition, @team, @qualifications, @finals).deliver

  end

  def results
    
    #get all the teams
    @teams = @current_competition.teams.includes(:robot_scores, :project_scores, :corevalue_scores)
    
    #sort by qualification score, highest first, and rank them
    @teams.sort! {|a,b| b.average_qual_score <=> a.average_qual_score}
    last_score = -1
    last_rank = 1
    @teams.each_with_index do |team, index|
      score = team.average_qual_score || 0
      if last_score >= 0
        if score == last_score
          team_rank = last_rank
        else
          team_rank = index + 1
        end
      else
        team_rank = index + 1
      end
      last_rank = team_rank
      team.performance_rank = team_rank
      last_score = score
    end

    #rank robot project scores
    @teams.sort! {|a,b| b.robot_scores_total <=> a.robot_scores_total }
    last_score = -1
    last_rank = 1
    @teams.each_with_index do |team, index|
      score = team.robot_scores_total
      if last_score >= 0
        if score == last_score
          team_rank = last_rank
        else
          team_rank = index + 1
        end
      else
        team_rank = index + 1
      end
      last_rank = team_rank
      team.robot_scores_rank = team_rank
      last_score = score
    end
 
    
    # Calculate robot ranking score (robot presentation score + ranking)
    @teams.each do |team|
      team.total_score = (team.robot_scores_rank / 2) + (team.performance_rank / 2)
    end
    
    #rank robot scores
    @teams.sort! {|a,b| b.total_score <=> a.total_score }
    last_score = -1
    last_rank = 1
    @teams.each_with_index do |team, index|
      score = team.total_score
      if last_score >= 0
        if score == last_score
          team_rank = last_rank
        else
          team_rank = index + 1
        end
      else
        team_rank = index + 1
      end
      last_rank = team_rank
      team.total_rank = team_rank
      last_score = score
    end
    
    #sort project scores and rank them, highest first
    @teams = @teams.sort {|a,b| b.project_scores_total <=> a.project_scores_total }
    last_score = -1
    last_rank = 1
    @teams.each_with_index do |team, index|
      score = team.project_scores_total
      if last_score >= 0
        if score == last_score
          team_rank = last_rank
        else
          team_rank = index + 1
        end
      else
        team_rank = index + 1
      end
      team.project_rank = team_rank
      last_rank = team_rank
      last_score = score
    end
    
    #sort core values scores and rank them, highest first
    @teams.sort! {|a,b| b.corevalue_scores_total <=> a.corevalue_scores_total }
    last_score = -1
    last_rank = 1
    @teams.each_with_index do |team, index|
      score = team.corevalue_scores_total
      if last_score >= 0
        if score == last_score
          team_rank = last_rank
        else
          team_rank = index + 1
        end
      else
        team_rank = index + 1
      end
      last_rank = team_rank
      team.corevalue_rank = team_rank
      last_score = score
    end
    
    #calculate champion score
    @teams.each do |team|
      team.champion_score = team.total_rank + team.project_rank + team.corevalue_rank
    end
    
    #sort champion scores and rank them, LOWEST first
    @teams.sort! {|a,b| a.champion_score <=> b.champion_score }
    last_score = -1
    last_rank = 1
    @teams.each_with_index do |team, index|
      score = team.champion_score
      if last_score >= 0
        if score == last_score
          team_rank = last_rank
        else
          team_rank = index + 1
        end
      else
        team_rank = index + 1
      end
      last_rank = team_rank
      team.champion_rank = team_rank
      last_score = score
    end
    
    #finally sort by team number
    @teams.sort! {|a,b| a.fll_number <=> b.fll_number}
    
  end

private
  def authenticate
    if current_competition == nil
      redirect_to root_url
    end
  end
end
