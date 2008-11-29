class MatchesController < ApplicationController
  
  def new
    @team = Team.find params[:team_id]
    @match = Match.new
  end
  
  def index
    @matches = Match.find(:all)
  end
  
  def show
    @matches = Match.match_list(params[:id])
    @match_number = params[:id]
  end
  
  def edit
    @team = Team.find(params[:team_id])
    @match = @team.matches.find(params[:id])
  end
  
  def update
     @team = Team.find(params[:team_id])
     @match = @team.matches.find(params[:id])
     if @match.update_attributes(params[:match])

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
         @match.score = $challenge.score(results)
         @match.save
         
         redirect_to team_path(@team)
       else
         err = "Please correct the following: <br>"
         $errors.each { |error| err += error + "<br>" }
         flash[:notice] = err
         render :action => "edit"
       end
     else
       render :action  => "edit"
     end
   end
  
  def create
    @team = Team.find params[:team_id]
    @match = @team.matches.build(params[:match])
    @match.results = params[:results]
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
        @match.score = $challenge.score(results)
        @match.save
        redirect_to :controller => "teams"
      else
        err = "Please correct the following: <br>"
        $errors.each { |error| err += error + "<br>" }
        flash[:notice] = err
        render :action => "new"
      end
    else
      render :action  => "new"
    end
  end
end
