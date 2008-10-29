class Match < ActiveRecord::Base
   
    belongs_to :team
    serialize :results
end
