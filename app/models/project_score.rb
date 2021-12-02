class ProjectScore < ActiveRecord::Base

  belongs_to :team
  before_save :calculate_total_scores
  validates :judge_name, :presence => true
  # validates :rank, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 20 }

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

  def award_count
    ((self.award_research || "N") + (self.award_innosolution || "N") + (self.award_presentation || "N")).count("Y")
  end

  private
    def calculate_total_scores
      self.total_score = identify + identify2 + design + design2 + create + create2 + iterate + iterate2 + communicate + communicate2

    end
end
