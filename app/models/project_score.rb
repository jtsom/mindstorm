class ProjectScore < ActiveRecord::Base
  
  belongs_to :team
  before_save :calculate_total_score
  validates :judge_name, :presence => true
  
  def research_score
    fields = %w{r_problemID r_source r_analysis r_review }
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end
  
  def innovative_score
    fields = %w{i_teamsolution i_innovation i_implementation }
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end
  
  def pres_score
    fields = %w{p_preseffective p_creativity p_sharing }
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end

  private
    def calculate_total_score
      self.total_score = research_score + innovative_score + pres_score

    end  
end
