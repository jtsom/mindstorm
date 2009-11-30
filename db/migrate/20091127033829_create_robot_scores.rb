class CreateRobotScores < ActiveRecord::Migration
  def self.up
    create_table :robot_scores do |t|
      t.total_score

      t.integer :inno_design
      
      t.integer :strategy1
      t.integer :strategy2
      
      t.integer :loconav1
      t.integer :loconav2
      t.integer :loconav3
      t.integer :loconav4
      t.integer :loconav5
      
      t.integer :prog1
      t.integer :prog2
      t.integer :prog3
      t.integer :prog4
      t.integer :prog5
      t.integer :prog6
      t.integer :prog7
      t.integer :prog8
      
      t.integer :kids1
      t.integer :kids2
      t.integer :kids3
      
      t.integer :structural1
      t.integer :structural2
      t.integer :structural3
      t.integer :structural4
      t.integer :structural5
      
      t.integer :overall1
      t.integer :overall2
      t.integer :overall3
      
      
      t.timestamps
    end
  end

  def self.down
    drop_table :robot_scores
  end
end
