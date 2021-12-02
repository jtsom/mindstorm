class FixColumnNames < ActiveRecord::Migration[5.1]
  def change
    rename_column :robot_scores, :communicate2_exceel, :communicate2_exceed
    rename_column :robot_scores, :communicate_exceel, :communicate_exceed
    rename_column :corevalue_scores, :teamwork_exceel, :teamwork_exceed
    rename_column :project_scores, :communicate_exceel, :communicate_exceed
    rename_column :project_scores, :communicate2_exceel, :communicate2_exceed


  end
end
