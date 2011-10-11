class MatchesController < ApplicationController

  before_filter :get_class
  
  def new
    @team = Team.find params[:team_id]
    @match = @match_class.new
		render  "matches/new"
  end
  
  def index
		@matches = @match_class.order(:match_number)
		respond_to do |wants|
       wants.html { render "matches/index" }
       wants.xml {render :xml => @matches }
       wants.json {render :json => @matches }
     end
		#render "matches/index"
  end
  
  def show
    @matches = @match_class.match_list(params[:id])
    @match_number = params[:id]
    respond_to do |format|
      format.html {render "matches/show" }
      format.xml {render :xml => @matches }
    end
  end
  
  def destroy
    team = Team.find(params[:team_id])
    match = @match_class.find(params[:id])
    match.destroy
    flash[:notice] = "Match #{match.match_number} for team #{team.fll_number} deleted."
    redirect_to :action => "index"
  end
  
  def edit
    @team = Team.find(params[:team_id])
		@match = @match_class.find(params[:id])
    render "matches/edit"
  end
  
  def update
     @team = Team.find(params[:team_id])
     @match = @match_class.find(params[:id])

     results = {}
     params[:results].each_pair do |key, value|
       results[key.to_sym] = case value
         when "y", "Y" then 1
         when "n", "N" then 0
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
       flash[:notice] = err.html_safe
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
          when "y", "Y" then 1
          when "n", "N" then 0
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
        flash[:notice] = err.html_safe
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
