class NewJudgingScoring < ActiveRecord::Migration[5.1]
  def change
    add_column :corevalue_scores, :discovery, :integer
    add_column :corevalue_scores, :discovery_exceed, :text
    add_column :corevalue_scores, :innovation, :integer
    add_column :corevalue_scores, :innovation_exceed, :text
    add_column :corevalue_scores, :impact, :integer
    add_column :corevalue_scores, :impact_exceed, :text
    add_column :corevalue_scores, :inclusion, :integer
    add_column :corevalue_scores, :inclusion_exceed, :text
    # - existing add_column :corevalue_scores, :teamwork, :integer
    add_column :corevalue_scores, :teamwork_exceel, :text
    add_column :corevalue_scores, :fun, :integer
    add_column :corevalue_scores, :fun_exceed, :text

    add_column :project_scores, :identify, :integer
    add_column :project_scores, :identify_exceed, :text
    add_column :project_scores, :design, :integer
    add_column :project_scores, :design_exceed, :text
    add_column :project_scores, :create, :integer
    add_column :project_scores, :create_exceed, :text
    add_column :project_scores, :iterate, :integer
    add_column :project_scores, :iterate_exceed, :text
    add_column :project_scores, :communicate, :integer
    add_column :project_scores, :communicate_exceel, :text

    add_column :project_scores, :identify2, :integer
    add_column :project_scores, :identify2_exceed, :text
    add_column :project_scores, :design2, :integer
    add_column :project_scores, :design2_exceed, :text
    add_column :project_scores, :create2, :integer
    add_column :project_scores, :create2_exceed, :text
    add_column :project_scores, :iterate2, :integer
    add_column :project_scores, :iterate2_exceed, :text
    add_column :project_scores, :communicate2, :integer
    add_column :project_scores, :communicate2_exceel, :text

    add_column :robot_scores, :identify, :integer
    add_column :robot_scores, :identify_exceed, :text
    add_column :robot_scores, :design, :integer
    add_column :robot_scores, :design_exceed, :text
    add_column :robot_scores, :create, :integer
    add_column :robot_scores, :create_exceed, :text
    add_column :robot_scores, :iterate, :integer
    add_column :robot_scores, :iterate_exceed, :text
    add_column :robot_scores, :communicate, :integer
    add_column :robot_scores, :communicate_exceel, :text

    add_column :robot_scores, :identify2, :integer
    add_column :robot_scores, :identify2_exceed, :text
    add_column :robot_scores, :design2, :integer
    add_column :robot_scores, :design2_exceed, :text
    add_column :robot_scores, :create2, :integer
    add_column :robot_scores, :create2_exceed, :text
    add_column :robot_scores, :iterate2, :integer
    add_column :robot_scores, :iterate2_exceed, :text
    add_column :robot_scores, :communicate2, :integer
    add_column :robot_scores, :communicate2_exceel, :text

  end
end
