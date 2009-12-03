class MatchesController < ApplicationController

  before_filter :get_class
  
  def new
    @team = Team.find params[:team_id]
    @match = @match_class.new
		render  "matches/new"
  end
  
  def index
		@matches = @match_class.find(:all, :order => "match_number")
		render "matches/index"
  end
  
  def show
    @matches = Match.match_list(params[:id])  
    case params[:controller]
      when "qualifications"
        @matches = @matches.qual_matches
      when "finals"
        @matches = @matches.final_matches
    end
    @match_number = params[:id]
    render "matches/show"
  end
  
  def edit
    @team = Team.find(params[:team_id])
		@match = @match_class.find(params[:id])
    render "matches/edit"
  end
  
  def update
     @team = Team.find(params[:team_id])
     @match = case params[:controller]
         when "qualifications"
           @team.qualifications.find(params[:id])
         when "finals"
           @team.finals.find(params[:id])
       end


     results = {}
     params[:results].each_pair do |key, value|
       results[key.to_sym] = case value
         when "y", "Y" : 1
         when "n", "N" : 0
         else value.to_i
       end
     end
     
     @match.attributes = params[params[:controller].singularize.to_sym]
     @match.results = results

     if $challenge.check(results)
       
       @match.score = $challenge.score(results)
       if @match.save
         flash[:notice] = "Results for match #{@match.match_number} updated."
         redirect_to teams_path
       else
          render "matches/edit"
       end
     else
       err = "Please correct the following: <br>"
       $errors.each { |error| err += error + "<br>" }
       flash[:notice] = err
       render  "matches/edit"
     end

   end
  
  def create
    @team = Team.find params[:team_id]

    @match = @match_class.new(params[params[:controller].singularize.to_sym])

    if @match.valid?
      results = {}
      params[:results].each_pair do |key, value|
        results[key.to_sym] = case value
          when "y", "Y" : 1
          when "n", "N" : 0
          else value.to_i
        end
      end
    
      @match.results = results
    
      if $challenge.check(results)
        flash[:notice] = "Results for match #{@match.match_number} saved."
        @match.score = $challenge.score(results)
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
        flash[:notice] = err
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
end
