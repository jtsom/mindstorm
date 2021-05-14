class Competition < ActiveRecord::Base
  has_many :teams
  validates :name, :presence => true
  validates :password, :presence => true
  validates :from_email, :presence => true
  validates :full_name, :presence => true
  validates :contact_name, :presence => true
  validates :judge_lanes, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }

  def self.authenticate(competition_name, password)
    competition = find_by name: competition_name.downcase
    if competition && competition.password.downcase == password.downcase
      competition
    else
      nil
    end
  end

end
