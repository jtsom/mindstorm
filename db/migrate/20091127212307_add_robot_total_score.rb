class AddRobotTotalScore < ActiveRecord::Migration
  def self.up
    add_column :robot_scores, :total_score, :integer
  end

  def self.down
    remove_column :robot_scores, :total_score
  end
end
