class Competition < ActiveRecord::Base
  has_many :teams
  
  def self.authenticate(competition_name, password)
    competition = find_by_name(competition_name)
    if competition && competition.password == password
      competition
    else
      nil
    end
  end
  
end
