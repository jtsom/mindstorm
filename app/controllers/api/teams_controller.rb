module Api
	class TeamsController < ApplicationController
		respond_to :json

		def index
			@teams = Team.where("competition_id = ?", params[:competition_id])
			@teams.sort! {|a,b| a.fll_number <=> b.fll_number}
			respond_with @teams
		end

		def show
			team = Team.where("id = ?", params[:id])
			respond_with team
		end
	end
end