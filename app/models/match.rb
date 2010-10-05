class Match < ActiveRecord::Base
   
    serialize :results
    
    #validates_presence_of :match_number, :message => "can't be blank"
    validates :match_number, :presence => true #, :message  => "can not be blank"
    validates :table_number, :presence => true
    validates :match_number, :uniqueness => {:scope => [:team_id, :type] }
    
    validates_exclusion_of :table_number, :in => [1..APP_CONFIG["max_matches"]], :message => "between 1 and #{APP_CONFIG["max_matches"]}"
    
    scope :match_list, lambda { |match_number| {:conditions => ["match_number = ?", match_number ]}}
    
    scope :qual_matches, :conditions => {:type => "Qualification"}
    scope :final_matches, :conditions => {:type => "Final"}
    
    MATCH_TYPES = [['Qualification' , 'Q'], ['Final' , 'F']]
    
end
