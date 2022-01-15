class AddGpScoreToMatches < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :GP_Score, :integer
  end
end
