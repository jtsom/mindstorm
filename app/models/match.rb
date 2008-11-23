class Match < ActiveRecord::Base
   
    belongs_to :team
    serialize :results
    validates_presence_of :match_number, :message => "can't be blank"
    validates_uniqueness_of :match_number, :scope => :team_id, :message => "for this team already exists"
    
end
