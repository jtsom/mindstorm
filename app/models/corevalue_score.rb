class CorevalueScore < ActiveRecord::Base
  belongs_to :team
  before_save :calculate_total_scores
  
  validates :judge_name, :presence => true
  
  # def inspiration_score
  #   fields = %w{i_discovery i_team_spirit i_integration}
  #   fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }  
  # end
  # 
  # def teamwork_score
  #   fields = %w{t_effectiveness t_efficiency t_initiative}
  #   fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  # end
  # 
  # def gp_score
  #   fields = %w{g_inclusion g_respect g_coopertition}
  #   fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  # end
  def award_count
    ((self.award_inspiration || "N") + (self.award_teamwork || "N") + (self.award_gracprof || "N")).count("Y")
  end
  
private
  def calculate_total_scores
    self.inspiration = i_discovery + i_team_spirit + i_integration
    self.teamwork = t_effectiveness + t_efficiency + t_initiative
    self.grac_prof = g_inclusion + g_respect + g_coopertition
    self.total_score = self.inspiration + self.teamwork + self.grac_prof
  end
  

end

