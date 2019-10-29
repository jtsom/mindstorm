class AddNewCommentFields < ActiveRecord::Migration[5.1]
  def change
    add_column :corevalue_scores, :cv_gj_comments, :text
    add_column :corevalue_scores, :cv_ta_coments, :text
    add_column :project_scores, :p_gj_comments, :text
    add_column :project_scores, :p_ta_comments, :text
    add_column :robot_scores, :r_gj_comments, :text
    add_column :robot_scores, :r_ta_comments, :text
  end
end
