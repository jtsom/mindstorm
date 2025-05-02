module Api
	class CompetitionsController < ApplicationController
		respond_to :json

		def index
			respond_with Competition.all.order(:name).as_json(only: [:name, :full_name, :id])
		end

		def show
			respond_with Competition.find(params[:id]).as_json(only: [:name, :full_name, :id])
		end

		def standings
			teams = Competition.find(params[:id]).teams.includes(:qualifications).order(high_score: :desc)
		end
	end
end
