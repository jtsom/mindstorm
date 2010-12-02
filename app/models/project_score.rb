class ProjectScore < ActiveRecord::Base
  
  belongs_to :team
  before_save :calculate_total_scores
  validates :judge_name, :presence => true
  
  # def research_score
  #   fields = %w{r_problemID r_source r_analysis r_review }
  #   fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  # end
  # 
  # def innovative_score
  #   fields = %w{i_teamsolution i_innovation i_implementation }
  #   fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  # end
  # 
  # def pres_score
  #   fields = %w{p_preseffective p_creativity p_sharing }
  #   fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  # end

  private
    def calculate_total_scores
      self.research = r_problemID + r_source + r_analysis + r_review
      self.innovative_solution = i_teamsolution + i_innovation + i_implementation
      self.presentation = p_preseffective + p_creativity + p_sharing 
      self.total_score = self.research + self.innovative_solution + self.presentation

    end  
end
