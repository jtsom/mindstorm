class RobotScore < ActiveRecord::Base

  belongs_to :team

  before_save :calculate_total_scores
  validates :judge_name, :presence => true
  validates :rank, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 20 }


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
      self.total_score = identify + identify2 + design + design2 + create + create2 + iterate + iterate2 + communicate + communicate2
    end
end
