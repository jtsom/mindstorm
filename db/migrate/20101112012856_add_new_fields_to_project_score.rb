class AddNewFieldsToProjectScore < ActiveRecord::Migration
  def self.up
    add_column :project_scores, :r_problemID, :integer
    add_column :project_scores, :r_source, :integer
    add_column :project_scores, :r_analysis, :integer
    add_column :project_scores, :r_review, :integer
    add_column :project_scores, :r_comments, :text
    add_column :project_scores, :i_teamsolution, :integer
    add_column :project_scores, :i_innovation, :integer
    add_column :project_scores, :i_implementation, :integer
    add_column :project_scores, :i_comments, :text
    add_column :project_scores, :p_preseffective, :integer
    add_column :project_scores, :p_creativity, :integer
    add_column :project_scores, :p_sharing, :integer
    add_column :project_scores, :p_comments, :text
  end

  def self.down
    remove_column :project_scores, :p_comments
    remove_column :project_scores, :p_sharing
    remove_column :project_scores, :p_creativity
    remove_column :project_scores, :p_preseffective
    remove_column :project_scores, :i_comments
    remove_column :project_scores, :i_implementation
    remove_column :project_scores, :i_innovation
    remove_column :project_scores, :i_teamsolution
    remove_column :project_scores, :r_comments
    remove_column :project_scores, :r_review
    remove_column :project_scores, :r_analysis
    remove_column :project_scores, :r_source
    remove_column :project_scores, :r_problemID
  end
end