class CorevalueScore < ActiveRecord::Base
  belongs_to :team
  before_save :calculate_total_score
  
  def inspiration_score
    fields = %w{i_discovery i_team_spirit i_integration}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }  
  end
  
  def teamwork_score
    fields = %w{t_effectiveness t_efficiency t_initiative}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end
  
  def gp_score
    fields = %w{g_inclusion g_respect g_coopertition}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end
private
  def calculate_total_score
    self.total_score = inspiration_score + teamwork_score + gp_score
  end
end

