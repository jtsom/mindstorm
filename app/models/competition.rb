class Competition < ActiveRecord::Base
  has_many :teams
  
  def self.authenticate(competition_name, password)
    competition = find_by_name(competition_name.downcase)
    if competition && competition.password.downcase == password.downcase
      competition
    else
      nil
    end
  end
  
end
