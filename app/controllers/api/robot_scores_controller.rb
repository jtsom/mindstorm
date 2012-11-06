module Api
	class RobotScoresController < ApplicationController
		respond_to :json

		def index
			respond_with RobotScore.where("team_id = ?", params[:team_id])
			
		end
	end
end