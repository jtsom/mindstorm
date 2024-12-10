module Api
	class TeamsController < ApplicationController
		respond_to :json

		def index
			teams = Team.includes(:qualifications).where("competition_id = ?", params[:competition_id]).order(:fll_number)
			respond_with teams.to_json(only: [:fll_number, :team_name, :coach, :town], include: [qualifications: {}])
		end

		def show
			team = Team.includes(:qualifications).find(params[:id])
			x = team.to_json(only: [:fll_number, :team_name, :coach, :town], include: [qualifications: {}])
			# respond_with team.as_json(only: [:fll_number, :team_name, :coach, :town, :qualifications]), include: {qualifications: {}}
			respond_with team.to_json(only: [:fll_number, :team_name, :coach, :town], include: [qualifications: {}])
		end

	end
end
