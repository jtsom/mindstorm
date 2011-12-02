class RobotScore < ActiveRecord::Base
  
  belongs_to :team
  
  before_save :calculate_total_scores
  validates :judge_name, :presence => true

  
  
  # def mechanical_score
  #   fields = %w{m_durability m_efficiency m_mechanization}
  #   fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }  
  # end
  # 
  # def programming_score
  #   fields = %w{p_quality p_efficiency p_automation}
  #   fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0)  } 
  # end
  # 
  # def innovation_score
  #   fields = %w{i_designprocess i_strategy i_innovation}
  #   fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  # end
  
  def award_count
    ((self.award_mechdesign || "N") + (self.award_programming || "N") + (self.award_strategy || "N") ).count("Y")
  end
  
private
    def calculate_total_scores
      self.mechanical_design = m_durability + m_efficiency + m_mechanization
      self.programming = p_quality + p_efficiency + p_automation
      self.innovation_strategy = i_designprocess + i_strategy + i_innovation
      self.total_score = self.mechanical_design + self.programming + self.innovation_strategy
    end
end
