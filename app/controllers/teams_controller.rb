class TeamsController < ApplicationController
  # GET /teams
  # GET /teams.xml
  def index
    @teams = Team.find(:all, :include => [:finals, :qualifications], :order => :fll_number)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @teams }
    end
  end

  def standings
    @teams = Team.find(:all, :include => :qualifications).sort {|a,b| b.average_qual_score <=> a.average_qual_score}
  end
  
  def results
    
    @teams=Team.find(:all, :include => [:robot_score, :project_score]).sort {|a,b| a.fll_number <=> b.fll_number}

  end
  
  # GET /teams/1
  # GET /teams/1.xml
  def show
    @team = Team.find(params[:id])
    @qualifications = @team.qualifications.find(:all, :order => :match_number)
    @finals = @team.finals.find(:all, :order => :match_number)

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
  
  def get_robot_ranking
    @robot_rank = {}
    teams = Team.find(:all, :include => :robot_score).sort {|a,b| b.total_robot_score <=> a.total_robot_score}
    teams.each_with_index do |team, i|
      @robot_rank[team.fll_number.to_s.to_sym] = i + 1
    end
  end
  
  def get_project_ranking
    @project_rank = {}
    teams = Team.find(:all, :include => :project_score).sort {|a,b| b.total_project_score <=> a.total_project_score}
    teams.each_with_index do |team, i|
      @project_rank[team.fll_number.to_s.to_sym] = i + 1
    end
  end
end
