class AddTeamIdToScoreTables < ActiveRecord::Migration
  def self.up
    add_column :project_scores, :team_id, :integer
    add_column :robot_scores, :team_id, :integer
    
    add_index :project_scores, :team_id
    add_index :robot_scores, :team_id
  end

  def self.down
    remove_index :project_scores, :team_id
    remove_index :robot_scores, :team_id
    remove_column :robots_cores, :team_id
    remove_column :project_scores, :team_id
  end
end
