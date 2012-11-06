module Api
	class FinalsController < ApplicationController
		respond_to :json

		def index
			respond_with Match.where('team_id = ?', params[:team_id])
			
		end
	end
end