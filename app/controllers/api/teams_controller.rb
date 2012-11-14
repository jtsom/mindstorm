module Api
	class TeamsController < ApplicationController
		respond_to :json

		def index
			@teams = Team.where("competition_id = ?", params[:competition_id]).includes([:qualifications, :finals])
			@teams.sort! {|a,b| a.fll_number <=> b.fll_number}
			respond_with @teams, :include => [:qualifications, :finals]
		end

		def show
			team = Team.where("id = ?", params[:id]).includes([:qualifications, :finals])
			respond_with team, :include => [:qualifications, :finals]
		end
	end
end