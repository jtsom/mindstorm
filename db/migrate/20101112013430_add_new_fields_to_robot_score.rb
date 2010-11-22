class AddNewFieldsToRobotScore < ActiveRecord::Migration
  def self.up
    add_column :robot_scores, :m_durability, :integer
    add_column :robot_scores, :m_efficiency, :integer
    add_column :robot_scores, :m_mechanization, :integer
    add_column :robot_scores, :m_comments, :text
    add_column :robot_scores, :p_quality, :integer
    add_column :robot_scores, :p_efficiency, :integer
    add_column :robot_scores, :p_automation, :integer
    add_column :robot_scores, :p_comments, :text
    add_column :robot_scores, :i_designprocess, :integer
    add_column :robot_scores, :i_strategy, :integer
    add_column :robot_scores, :i_innovation, :integer
    add_column :robot_scores, :i_comments, :text
  end

  def self.down
    remove_column :robot_scores, :i_comments
    remove_column :robot_scores, :i_innovation
    remove_column :robot_scores, :i_strategy
    remove_column :robot_scores, :i_designprocess
    remove_column :robot_scores, :p_comments
    remove_column :robot_scores, :p_automation
    remove_column :robot_scores, :p_efficiency
    remove_column :robot_scores, :p_quality
    remove_column :robot_scores, :m_comments
    remove_column :robot_scores, :m_mechanization
    remove_column :robot_scores, :m_efficiency
    remove_column :robot_scores, :m_durability
  end
end