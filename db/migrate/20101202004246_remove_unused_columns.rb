class RemoveUnusedColumns < ActiveRecord::Migration
  def self.up
         change_table :project_scores do |t|
             t.remove  "research1"
             t.remove  "research2"
             t.remove  "research3"
             t.remove  "research4"
             t.remove  "research5"
             t.remove  "research6"
             t.remove  "is1"
             t.remove  "is2"
             t.remove  "is3"
             t.remove  "sharing1"
             t.remove  "sharing2"
             t.remove  "pres1"
             t.remove  "pres2"
             t.remove  "pres3"
             t.remove  "pres4"
             t.remove  "pres5"
             t.remove  "pres6"
             t.remove  "pres7"
             t.remove  "pres8"
             t.remove  "pres9"
             t.remove  "pres10"
         end

         change_table :robot_scores do |t|
             t.remove  "inno_design"
             t.remove  "strategy1"
             t.remove  "strategy2"
             t.remove  "loconav1"
             t.remove  "loconav2"
             t.remove  "loconav3"
             t.remove  "loconav4"
             t.remove  "loconav5"
             t.remove  "prog1"
             t.remove  "prog2"
             t.remove  "prog3"
             t.remove  "prog4"
             t.remove  "prog5"
             t.remove  "prog6"
             t.remove  "prog7"
             t.remove  "prog8"
             t.remove  "kids1"
             t.remove  "kids2"
             t.remove  "kids3"
             t.remove  "structural1"
             t.remove  "structural2"
             t.remove  "structural3"
             t.remove  "structural4"
             t.remove  "structural5"
             t.remove  "overall1"
             t.remove  "overall2"
             t.remove  "overall3"
         end

   end

   def self.down

         change_table :project_scores do
             t.integer  "research1"
             t.integer  "research2"
             t.integer  "research3"
             t.integer  "research4"
             t.integer  "research5"
             t.integer  "research6"
             t.integer  "is1"
             t.integer  "is2"
             t.integer  "is3"
             t.integer  "sharing1"
             t.integer  "sharing2"
             t.integer  "pres1"
             t.integer  "pres2"
             t.integer  "pres3"
             t.integer  "pres4"
             t.integer  "pres5"
             t.integer  "pres6"
             t.integer  "pres7"
             t.integer  "pres8"
             t.integer  "pres9"
             t.integer  "pres10"
         end

         change_table :robot_scores do
             t.integer  "inno_design"
             t.integer  "strategy1"
             t.integer  "strategy2"
             t.integer  "loconav1"
             t.integer  "loconav2"
             t.integer  "loconav3"
             t.integer  "loconav4"
             t.integer  "loconav5"
             t.integer  "prog1"
             t.integer  "prog2"
             t.integer  "prog3"
             t.integer  "prog4"
             t.integer  "prog5"
             t.integer  "prog6"
             t.integer  "prog7"
             t.integer  "prog8"
             t.integer  "kids1"
             t.integer  "kids2"
             t.integer  "kids3"
             t.integer  "structural1"
             t.integer  "structural2"
             t.integer  "structural3"
             t.integer  "structural4"
             t.integer  "structural5"
             t.integer  "overall1"
             t.integer  "overall2"
             t.integer  "overall3"
         end
   end
end