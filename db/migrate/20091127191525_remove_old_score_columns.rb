class RemoveOldScoreColumns < ActiveRecord::Migration
  def self.up
    remove_column :teams, :project_score
    remove_column :teams, :technical_score
  end

  def self.down
    add_column :teams, :project_score, :integer
    add_column :teams, :technical_score, :integer
  end
end
