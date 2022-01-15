class MatchesController < ApplicationController

  before_action :authenticate
  before_action :get_class

  def new
    # <%= match_fields.text_field item.label, { :value => value, :size  => max_length, :maxlength => max_length, :onkeypress => val_func } %> <%= allowed_values %>
    @team = @current_competition.teams.find params[:team_id]
    @match = @match_class.new
    @match.GP_Score = "3" # all teams start at 3
		render  "matches/new"
  end

  def index
		#@matches = @match_class.order(:match_number)
		teams = @current_competition.teams

		# Get matches for teams in current competition
		@matches = []
		teams.each do |team|
		  case params[:controller]
    	  when "qualifications"
    	    all_matches = team.qualifications
        when "finals"
          all_matches = team.finals
      end
	    if all_matches && !all_matches.empty?
	      @matches.concat(all_matches)
	    end
	  end

	  @matches = @matches.sort_by {|t| [t[:match_number], t[:table_number]] }

		respond_to do |wants|
       wants.html { render "matches/index" }
       wants.xml {render :xml => @matches }
       wants.json {render :json => @matches }
     end
		#render "matches/index"
  end

  def show

    teams = @current_competition.teams

		# Get matches for teams in current competition
		@matches = []
		teams.each do |team|
		  case params[:controller]
    	  when "qualifications"
    	    all_matches = team.qualifications
        when "finals"
          all_matches = team.finals
      end
	    if all_matches && !all_matches.empty?
	      all_matches.each do |match|
	        if match.match_number.to_s == params[:id].to_s
	          @matches << match
          end
        end
	      #@matches.concat(all_matches)
	    end
	  end

	  @matches = @matches.sort {|a,b| a.match_number <=> b.match_number }

    @match_number = params[:id]
    respond_to do |format|
      format.html {render "matches/show" }
      format.xml {render :xml => @matches }
    end
  end

  def destroy
    team = @current_competition.teams.find(params[:team_id])
    match = @match_class.find(params[:id])
    match.destroy
    flash[:notice] = "Match #{match.match_number} for team #{team.fll_number} deleted."
    redirect_to :action => "index"
  end

  def edit
    # <%= match_fields.text_field item.label, { :value => value, :size  => max_length, :maxlength => max_length, :onkeypress => val_func } %> <%= allowed_values %>
    @team = @current_competition.teams.find(params[:team_id])
		@match = @match_class.find(params[:id])
    render "matches/edit"
  end

  def update
     @team = @current_competition.teams.find(params[:team_id])
     @match = @match_class.find(params[:id])

     results = {}
     params[:results].each_pair do |key, value|
       results[key.to_sym] = case value
         when "y", "Y" then 1
         when "n", "N" then 0
         else value
       end
     end

     @match.match_number = params[params[:controller].singularize.to_sym][:match_number]
     @match.table_number = params[params[:controller].singularize.to_sym][:table_number]
     @match.results = results
     @match.GP_Score = params[params[:controller].singularize.to_sym][:GP_Score]

     if $challenge.check(results)

       @match.score = $challenge.score(results)
       @match.challenge_year = $challenge.mission_year
       if @match.save
         flash[:notice] = "Results for match #{@match.match_number} updated."
         case params[:controller]
           when "qualifications"
             redirect_to qualifications_path :anchor => "match_#{@match.match_number}"
           when "finals"
             redirect_to finals_path :anchor => "match_#{@match.match_number}"
         end
       else
          render "matches/edit"
       end
     else
       err = "Please correct the following: <br>"
       $errors.each { |error| err += error + "<br>" }
       flash[:notice] = err.html_safe
       render  "matches/edit"
     end

   end

  def create
    @team = @current_competition.teams.find params[:team_id]

    @match = @match_class.new()
    @match.match_number = params[params[:controller].singularize.to_sym][:match_number]
    @match.table_number = params[params[:controller].singularize.to_sym][:table_number]
    @match.GP_Score = params[params[:controller].singularize.to_sym][:GP_Score]
    @match.team_id = params[:team_id]
    puts "##########################"
puts params
puts "##########################"
    if @match.valid?
      results = {}
      params[:results].each_pair do |key, value|
        results[key.to_sym] = case value
          when "y", "Y" then 1
          when "n", "N" then 0
          else value
        end
      end

      @match.results = results

      if $challenge.check(results)
        flash[:notice] = "Results for match #{@match.match_number} saved."
        @match.score = $challenge.score(results)
        @match.challenge_year = $challenge.mission_year
        @match.save
        case params[:controller]
          when "qualifications"
            @team.qualifications << @match
          when "finals"
            @team.finals << @match
        end

        redirect_to :controller => "teams"
      else
        err = "Please correct the following: <br>"
        $errors.each { |error| err += error + "<br>" }
        flash[:notice] = err.html_safe
        # debugger
        render  "matches/new"
      end
    else
      render  "matches/new"
    end
  end

private

	def get_class
		@match_class=params[:controller].classify.constantize
	end

  def authenticate
    if current_competition == nil
      redirect_to root_url
    end
  end

  def match_params
    params.permit(params[params[:controller].singularize.to_sym]).permit(params[params[:controller].singularize.to_sym]).permit(:GP_Score)
  end
end
