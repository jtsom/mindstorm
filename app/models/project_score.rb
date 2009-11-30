class ProjectScore < ActiveRecord::Base
  
  belongs_to :team
  before_save :calculate_total_score

  
  def research_score
    fields = %w{research1 research2 research3 research4 research5}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) } 
  end
  
  def innovative_score
    fields = %w{is1 is2 is3}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end
  
  def sharing_score
    fields = %w{sharing1 sharing2}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end
  
  def pres_score
    fields = %w{pres1 pres2 pres3 pres4 pres5 pres6 pres7 pres8 pres9 pres10}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end

  def teamwork_score
    research_score + sharing_score + pres_score
  end
  
  private
    def calculate_total_score
      fields = %w{research1 research2 research3 research4 research5 is1 is2 is3 sharing1 sharing2 pres1 pres2 pres3 pres4 pres5 pres6 pres7 pres8 pres9 pres10}

      self.total_score = fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }

    end  
end
