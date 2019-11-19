class AddJudgingRanks < ActiveRecord::Migration[5.1]
  def change
    add_column :corevalue_scores, :rank, :integer
    add_column :project_scores, :rank, :integer
    add_column :robot_scores, :rank, :integer
  end
end
