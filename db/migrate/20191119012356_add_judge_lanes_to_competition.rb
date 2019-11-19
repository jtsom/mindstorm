class AddJudgeLanesToCompetition < ActiveRecord::Migration[5.1]
  def change
    add_column :competitions, :judge_lanes, :integer
  end
end
