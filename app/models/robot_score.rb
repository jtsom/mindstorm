class RobotScore < ActiveRecord::Base
  
  belongs_to :team
  
  before_save :calculate_total_score
  validates :judge_name, :presence => true

  
  
  def mechanical_score
    fields = %w{m_durability m_efficiency m_mechanization}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }  
  end
  
  def programming_score
    fields = %w{p_quality p_efficiency p_automation}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0)  } 
  end
  
  def innovation_score
    fields = %w{i_designprocess i_strategy i_innovation}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end
  
private
    def calculate_total_score
      self.total_score = mechanical_score + programming_score + innovation_score
    end
end
