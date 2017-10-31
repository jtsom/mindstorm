class ApplicationController < ActionController::Base
  protect_from_forgery
  #require "challenge-2010.rb"
  helper_method :current_competition
  before_action :cors_preflight_check
  after_action :cors_set_access_control_headers

  def cors_set_access_control_headers
   headers['Access-Control-Allow-Origin'] = '*'
   headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
   headers['Access-Control-Allow-Headers'] = '*'
   headers['Access-Control-Max-Age'] = "1728000"
   headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
 end

 # If this is a preflight OPTIONS request, then short-circuit the
 # request, return only the necessary headers and return an empty
 # text/plain.

 def cors_preflight_check
   if request.method == :options
     headers['Access-Control-Allow-Origin'] = '*'
     headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
     headers['Access-Control-Allow-Headers'] = '*'
     headers['Access-Control-Max-Age'] = '1728000'
     render :text => '', :content_type => 'text/plain'
     headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
   end
 end

private
  def current_competition
    @current_competition ||= Competition.find(session[:competition]) if session[:competition]
  end
end
