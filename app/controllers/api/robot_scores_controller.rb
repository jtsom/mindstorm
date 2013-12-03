module Api
	class RobotScoresController < ApplicationController
		respond_to :json

		def index
			respond_with RobotScore.where("team_id = ?", params[:team_id])
			
		end

		def show
			respond_with RobotScore.find(params[:id])
		end
	end
end