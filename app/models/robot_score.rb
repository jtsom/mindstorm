class RobotScore < ActiveRecord::Base
  
  belongs_to :team
  
  before_save :calculate_total_score


  
  
  def strategy_score
    fields = %w{strategy1 strategy2}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }  
  end
  
  def loconav_score
    fields = %w{loconav1 loconav2 loconav3 loconav4 loconav5}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end
  
  def programming_score
    fields = %w{prog1 prog2 prog3 prog5 prog6  prog8}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0)  } 
  end
  
  def kids_score
    fields = %w{kids1 kids2 kids3}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end
  
  def structural_score
    fields = %w{structural1 structural2  structural4 structural5}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end
  
  def overall_score
    fields = %w{overall1 overall2 overall3}
    fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
  end
  
private
    def calculate_total_score
      fields = %w{inno_design strategy1 strategy2 loconav1 loconav2 loconav3 loconav4 loconav5 prog1 prog2 prog3 prog5 prog6  prog8 kids1 kids2 kids3 structural1 structural2  structural4 structural5 overall1 overall2 overall3}
      self.total_score = fields.inject(0) {|tot, fld| tot + (self.send("#{fld}") || 0) }
    end
end
