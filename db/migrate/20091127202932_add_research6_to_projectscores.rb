class AddResearch6ToProjectscores < ActiveRecord::Migration
  def self.up
    add_column :project_scores, :research6, :integer
  end

  def self.down
    remove_column :project_scores, :research6
  end
end
