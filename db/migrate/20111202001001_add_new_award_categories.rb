class AddNewAwardCategories < ActiveRecord::Migration
  def up
    add_column :corevalue_scores, :award_inspiration, :string
    add_column :corevalue_scores, :award_teamwork, :string
    add_column :corevalue_scores, :award_gracprof, :string
    add_column :project_scores, :award_research, :string
    add_column :project_scores, :award_innosolution, :string
    add_column :project_scores, :award_presentation, :string
    add_column :robot_scores, :award_mechdesign, :string
    add_column :robot_scores, :award_programming, :string
    add_column :robot_scores, :award_strategy, :string
    
  end

  def down
    remove_column :corevalue_scores, :award_gracprof
    remove_column :corevalue_scores, :award_teamwork
    remove_column :corevalue_scores, :award_inspiration
    
    remove_column :project_scores, :award_research
    remove_column :project_scores, :award_innosolution
    remove_column :project_scores, :award_presentation
    
    remove_column :robot_scores, :award_mechdesign
    remove_column :robot_scores, :award_programming
    remove_column :robot_scores, :award_strategy
    
  end
end