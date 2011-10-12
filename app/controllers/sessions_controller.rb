class SessionsController < ApplicationController
  def new
  end

  def create

    competition = Competition.authenticate(params[:competition_name], params[:password])
    
    if competition
      session[:competition_id] = competition.id
      redirect_to teams_path
    else
      flash.now.alert = "Invalid name or password!"
      render "new"
    end
  end
  
  def destroy
    session[:competition_id] = nil
    redirect_to login_path
  end
end
