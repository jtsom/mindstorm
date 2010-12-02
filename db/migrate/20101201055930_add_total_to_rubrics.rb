class AddTotalToRubrics < ActiveRecord::Migration
  def self.up
    change_table :robot_scores do |t|
      t.integer :mechanical_design
      t.integer :programming
      t.integer :innovation_strategy
    end
    
    change_table :project_scores do |t|
      t.integer :research
      t.integer :innovative_solution
      t.integer :presentation
    end
    
    change_table :corevalue_scores do |t|
      t.integer :inspiration
      t.integer :teamwork
      t.integer :grac_prof
    end
  end

  def self.down
    change_table :corevalue_scores do |t|
      t.remove :inspiration, :teamwork, :grac_prof
    end
    
    change_table :project_scores do |t|
      t.remove :research, :innovative_solution, :presentation
    end
    
    change_table :robot_scores do |t|
      t.remove :mechanical_design, :programming, :innovation_strategy
    end
  end
end