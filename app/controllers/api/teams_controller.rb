module Api
	class TeamsController < ApplicationController
		respond_to :json

		def index
			@teams = Team.includes(:qualifications).where("competition_id = ?", params[:competition_id]).order(:fll_number)
			respond_with @teams, :include => :qualifications
		end

		def show
			team = Team.includes(:qualifications).find(params[:id])
			respond_with team, :include => :qualifications
		end

	end
end
