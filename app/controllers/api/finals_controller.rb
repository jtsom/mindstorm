module Api
	class FinalsController < ApplicationController
		respond_to :json

		def index
			if params[:team_id]
				respond_with Final.where('team_id = ?', params[:team_id])
			end

			if params[:competition_id] && !params[:team_id]
				teams = Team.includes([:finals]).where("competition_id = ?", params[:competition_id])
				matches = []
				teams.each do |team|
					all_matches = team.finals
					if all_matches && !all_matches.empty?
	      				matches.concat(all_matches)
	      			end
	    		end
	    		respond_with matches.sort_by {|t| [t[:match_number], t[:table_number]] }
			end
		end
	end
end
