class AddJudgeName < ActiveRecord::Migration
  def self.up
    add_column :project_scores, :judge_name, :string
    add_column :robot_scores, :judge_name, :string
    add_column :corevalue_scores, :judge_name, :string
  end

  def self.down
    remove_column :corevalue_scores, :judge_name
    remove_column :robot_scores, :judge_name
    remove_column :project_scores, :judge_name
  end
end