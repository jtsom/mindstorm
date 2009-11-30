class CreateProjectScores < ActiveRecord::Migration
  def self.up
    create_table :project_scores do |t|
      
      t.integer :total_score
      
      t.integer :research1
      t.integer :research2
      t.integer :research3
      t.integer :research4
      t.integer :research5
      
      t.integer :is1
      t.integer :is2
      t.integer :is3
      
      t.integer :sharing1
      t.integer :sharing2
      
      t.integer :pres1
      t.integer :pres2
      t.integer :pres3
      t.integer :pres4
      t.integer :pres5
      t.integer :pres6
      t.integer :pres7
      t.integer :pres8
      t.integer :pres9
      t.integer :pres10
      
      t.timestamps
    end
  end

  def self.down
    drop_table :project_scores
  end
end
