class SessionsController < ApplicationController
  def new
  end

  def create

    competition = Competition.authenticate(params[:competition_name], params[:password])
    session[:testing] = "testing"
    if competition
      session[:competition] = competition.id
      redirect_to teams_path
    else
      flash.now.alert = "Invalid name or password!"
      render "new"
    end
  end
  
  def destroy
    session[:competition] = nil
    redirect_to login_path
  end
end
