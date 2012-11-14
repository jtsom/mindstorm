module Api
	class QualificationsController < ApplicationController
		respond_to :json

		def index
			if params[:team_id]
				respond_with Qualification.where('team_id = ?', params[:team_id])
			end

			if params[:competition_id] && !params[:team_id]
				teams = Team.where("competition_id = ?", params[:competition_id]).includes([:qualifications])
				matches = []
				teams.each do |team|
					all_matches = team.qualifications
					if all_matches && !all_matches.empty?
	      				matches.concat(all_matches)
	      			end
	    		end
	    		respond_with matches
			end
		end
	end
end