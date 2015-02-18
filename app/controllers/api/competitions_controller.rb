module Api
	class CompetitionsController < ApplicationController
		respond_to :json

		def index
			respond_with Competition.all.sort! {|a,b| a.name <=> b.name}
		end

		def show
			respond_with Competition.find(params[:id])
		end

		def standings
			teams = Competition.find(params[:id]).teams.includes(:qualifications).sort do |a,b| 
      			(b.high_score <=> a.high_score)
    		end
		end
	end
end