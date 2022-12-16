class TeamsController < ApplicationController

 before_action :authenticate

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

    @r_count = 0
    @p_count = 0
    @c_count = 0
    @team.robot_scores.each do |score|
      @r_count += score.award_count
    end
    @team.project_scores.each do |score|
      @p_count += score.award_count
    end
    @team.corevalue_scores.each do |score|
      @c_count += score.award_count
    end

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
    @team = @current_competition.teams.new(team_params)

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
      if @team.update_attributes(team_params)
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

    teams = JSON.parse(raw)
    puts @current_competition.id
    Team.where(competition_id: @current_competition.id).destroy_all

    if teams.count > 0
      teams.each { |team|
        puts team["TeamNumber"]
        teamName = team["TeamName"]
        if teamName.nil? || teamName.empty?
          teamName = "Team #{team["TeamNumber"]}"
        end
        @current_competition.teams.create(:fll_number => team["TeamNumber"],
         :team_name => teamName,
         :school => team["OrganizationName"],
         :town => team["City"],
         :coach => team["CoachName"],
         :coach_email => team["CoachEmail"],
         :asst_coach => team["AssistantCoach"],
         :asst_coach_email => team["AssistantCoachEmail"],
         :state => team["State"])
      }

      flash[:notice] = 'Team list uploaded.'
    end

    redirect_to :action => :index
  end

# Upload a match list
# Fields:
# fllTeamNumber,MatchNumber,TableNumber

  def matchupload

  	all_teams = @current_competition.teams
  	num_matches = Qualification.where(:team_id => all_teams.map(&:id)).length

  	if num_matches > 0
  		flash[:error] = 'Matches already exist. Cannot upload.'
  		redirect_to :action => :index
  		return
  	end

    raw_results = "{:robot_inspection=>'0',:complete_project_model=>'0',:fuel_units_in_truck=>'0',:fuel_unit_over_station=>'0',:energy_units_in_bin=>'0',:energy_unit_removed_from_bin=>'0',:solar_energy_units_removed=>'0',:your_field_connector_raised=>'0',:other_field_connector_raised=>'0',:hybrid_car_not_touching_ramp=>'0',:hybrid_unit_in_car=>'0',:energy_units_not_touching_turbine=>'0',:television_completely_raised=>'0',:energy_unit_in_television=>'0',:dinosaur_toy_in_left_home=>'0',:dinosaur_toy_with_energy_unit=>'0',:dinosaur_toy_with_battery=>'0',:energy_units_not_touching_powerplant=>'0',:energy_unit_not_touching_dam=>'0',:water_units_in_reservoir=>'0',:water_units_on_hook=>'0',:energy_units_in_plant=>'0',:energy_units_in_toy_factory=>'0',:mini_toy_released=>'0',:energy_units_in_battery_area=>'0',:precision=>'50'}"

  	results = eval(raw_results)

    uploaded = params[:match_import][:file]
    if uploaded
		raw = uploaded.read
		if raw.split("\r").length > 1
		  data = raw.split("\r")
		else
		  data = raw.split("\n")
		end

		if data[0] == "MATCH UPLOAD"
			data = data[1, data.length]
			puts "size=" + data.length.to_s

			data.each { |line|
			  puts "line=" + line
			  fields = line.split(",")
			  puts fields[0] + ' ' + fields[1] + ' ' + fields[2]

			  fll_number = fields[0].to_i
			  match_number = fields[1].to_i
			  table_number = fields[2].to_i
			  team = (all_teams.detect { |team| team[:fll_number] == fll_number})
			  if team
				  match = Qualification.create()

				  match.match_number = match_number
				  match.table_number = table_number
				  match.results = results
				  match.team_id = team.id
				  match.score = 0
				  match.challenge_year = $challenge.mission_year
          match.GP_Score = 3
				  match.save
			  end
			}

			flash[:notice] = 'Matches uploaded.'
		else
			flash[:error] = 'Incorrect file format!'
		end
	else
		flash[:error] = 'Please select a file.'
	end

    redirect_to :action => :index
  end

 def elimmatchupload

  	all_teams = @current_competition.teams
  	num_matches = Final.where(:team_id => all_teams.map(&:id)).length

  	if num_matches > 0
  		flash[:error] = 'Elim Matches already exist. Cannot upload.'
  		redirect_to :action => :index
  		return
  	end

    raw_results = "{:robot_inspection=>'0',:complete_project_model=>'0',:fuel_units_in_truck=>'0',:fuel_unit_over_station=>'0',:energy_units_in_bin=>'0',:energy_unit_removed_from_bin=>'0',:solar_energy_units_removed=>'0',:your_field_connector_raised=>'0',:other_field_connector_raised=>'0',:hybrid_car_not_touching_ramp=>'0',:hybrid_unit_in_car=>'0',:energy_units_not_touching_turbine=>'0',:television_completely_raised=>'0',:energy_unit_in_television=>'0',:dinosaur_toy_in_left_home=>'0',:dinosaur_toy_with_energy_unit=>'0',:dinosaur_toy_with_battery=>'0',:energy_units_not_touching_powerplant=>'0',:energy_unit_not_touching_dam=>'0',:water_units_in_reservoir=>'0',:water_units_on_hook=>'0',:energy_units_in_plant=>'0',:energy_units_in_toy_factory=>'0',:mini_toy_released=>'0',:energy_units_in_battery_area=>'0',:precision=>'50'}"

  	results = eval(raw_results)

    uploaded = params[:elim_match_import][:file]
    if uploaded
		raw = uploaded.read
		if raw.split("\r").length > 1
		  data = raw.split("\r")
		else
		  data = raw.split("\n")
		end

		if data[0] == "ELIM MATCH UPLOAD"
			data = data[1, data.length]
			puts "size=" + data.length.to_s

			data.each { |line|
			  puts "line=" + line
			  fields = line.split(",")
			  puts fields[0] + ' ' + fields[1] + ' ' + fields[2]

			  fll_number = fields[0].to_i
			  match_number = fields[1].to_i
			  table_number = fields[2].to_i
			  team = (all_teams.detect { |team| team[:fll_number] == fll_number})
			  if team
				  match = Final.create()

				  match.match_number = match_number
				  match.table_number = table_number
				  match.results = results
				  match.team_id = team.id
				  match.score = 0
				  match.challenge_year = $challenge.mission_year
          match.GP_Score = 3
				  match.save
			  end
			}

			flash[:notice] = 'Elims Matches uploaded.'
		else
			flash[:error] = 'Incorrect file format!'
		end
	else
		flash[:error] = 'Please select a file.'
	end

    redirect_to :action => :index
  end

  def standings
    @teams = @current_competition.teams.includes(:qualifications).sort do |a,b|
      (b.high_score <=> a.high_score)
      #comp.zero? ? (a.fll_number <=> b.fll_number) : comp
    end

    respond_to do |format|
      format.html
      format.xml { render :xml => @teams }
    end
  end

  def text_standings
    @teams = @current_competition.teams.includes(:qualifications).sort do |a,b|
      (a.fll_number <=> b.fll_number)
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @teams }
    end
  end

  def gp_scores
    @teams = @current_competition.teams.includes(:qualifications).sort do |a,b|
      (a.fll_number <=> b.fll_number)
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @teams }
    end
  end

  def all_teams
    judge = params[:judge]

    @teams=@current_competition.teams.includes(:robot_scores, :project_scores, :corevalue_scores).order(:fll_number)

    if judge != nil
      judge = judge.upcase
      keep_teams = []
      @teams.each do |team|
        keep = false
        team.robot_scores.each do |score|
          if score.judge_name.upcase == judge
            keep = true
          end
        end
        team.project_scores.each do |score|
          if score.judge_name.upcase == judge
            keep = true
          end
        end
        team.corevalue_scores.each do |score|
          if score.judge_name.upcase == judge
            keep = true
          end
        end
        if keep
          keep_teams << team
        end
      end

      @teams = keep_teams
    end
    puts @teams.count
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
    #@teams.sort! {|a,b| b.average_qual_score <=> a.average_qual_score}

    @teams = @teams.sort {|a,b| b.high_score <=> a.high_score}
    last_score = -1
    last_rank = 1
    @teams.each_with_index do |team, index|
      score = team.high_score || 0
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
    @teams = @teams.sort {|a,b| b.robot_scores_total <=> a.robot_scores_total }
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
    # @teams.each do |team|
    #   team.total_score = (team.robot_scores_rank / 2) + (team.performance_rank / 2)
    # end

    #rank robot scores
    # @teams.sort! {|a,b| b.total_score <=> a.total_score }
    # last_score = -1
    # last_rank = 1
    # @teams.each_with_index do |team, index|
    #   score = team.total_score
    #   if last_score >= 0
    #     if score == last_score
    #       team_rank = last_rank
    #     else
    #       team_rank = index + 1
    #     end
    #   else
    #     team_rank = index + 1
    #   end
    #   last_rank = team_rank
    #   team.total_rank = team_rank
    #   last_score = score
    # end

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
    @teams = @teams.sort {|a,b| b.corevalue_scores_total <=> a.corevalue_scores_total }
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

    # Total up awards considered
    @teams.each do |team|
      r_count = 0
      p_count = 0
      c_count = 0
      team.robot_scores.each do |score|
        r_count += score.award_count
      end
      team.project_scores.each do |score|
        p_count += score.award_count
      end
      team.corevalue_scores.each do |score|
        c_count += score.award_count
      end
      team.awards_count = r_count + p_count + c_count
    end

    #calculate champion score
    @teams.each do |team|
      team.champion_score = team.performance_rank + team.robot_scores_rank + team.project_rank + team.corevalue_rank
    end

    #sort champion scores and rank them
    @teams = @teams.sort {|a,b| a.champion_score <=> b.champion_score }
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
    case params[:type]
      when "team"
        @teams.sort! {|a,b| a.fll_number <=> b.fll_number}
      when "match"
        @teams.sort! {|a,b| a.performance_rank <=> b.performance_rank}
      when "robot"
        @teams.sort! {|a,b| a.robot_scores_rank <=> b.robot_scores_rank}
      when "project"
        @teams.sort! {|a,b| a.project_rank <=> b.project_rank}
      when "corevalues"
        @teams.sort! {|a,b| a.corevalue_rank <=> b.corevalue_rank}
      when "champion" || ""
        @teams.sort! {|a,b| a.champion_rank <=> b.champion_rank}
      when "awards"
        @teams.sort! {|a,b| b.awards_count <=> a.awards_count}
    end

    puts "type=" + params[:type] if params[:type]
  end

  def recalculate_scores
    teams = @current_competition.teams

    # Get matches for teams in current competition
    teams.each do |team|

      all_matches = team.qualifications
      if all_matches && !all_matches.empty?
        all_matches.each do |match|
          match.score = $challenge.score(match.results)
          match.save
        end
      end

      all_matches = team.finals
      if all_matches && !all_matches.empty?
        all_matches.each do |match|
          match.score = $challenge.score(match.results)
          match.save
        end
      end

    end
    flash[:notice] = 'Team scored have been recalculated.'
    redirect_to :controller => "teams"
  end

private
  def authenticate
    if current_competition == nil
      redirect_to root_url
    end
  end

  def team_params
    params.require(:team).permit(:fll_number, :team_name, :school, :town, :coach, :coach_email,
      :asst_coach, :asst_coach_email, :state)
  end
end
