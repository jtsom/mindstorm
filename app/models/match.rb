class Match < ActiveRecord::Base
   
    belongs_to :team
    serialize :results
    
    validates_uniqueness_of :match_number, :scope => :team_id, :message => "for this team already exists"
end
