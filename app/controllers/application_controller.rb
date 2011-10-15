class ApplicationController < ActionController::Base
  protect_from_forgery
  #require "challenge-2010.rb"
  helper_method :current_competition
  
private
  def current_competition

    @current_competition ||= Competition.find(session[:competition_id]) if session[:competition_id]
    
  end
end
