class AddJudgingScoresToTeam < ActiveRecord::Migration
  def self.up
    add_column :teams, :project_score, :integer
    add_column :teams, :technical_score, :integer
  end

  def self.down
    remove_column :teams, :technical_score
    remove_column :teams, :project_score
  end
end
