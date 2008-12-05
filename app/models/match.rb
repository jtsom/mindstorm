class Match < ActiveRecord::Base
   
    belongs_to :team
    serialize :results
    
    validates_presence_of :match_number, :message => "can't be blank"
    validates_presence_of :table_number, :message => "can't be blank"
    validates_uniqueness_of :match_number, :scope => :team_id, :message => "for this team already exists"
    
    validates_exclusion_of :table_number, :in => [1..6], :message => "between 1 and 6"
    
    named_scope :match_list, lambda { |match_number| {:conditions => ["match_number = ?", match_number ]}}
    
    
end
