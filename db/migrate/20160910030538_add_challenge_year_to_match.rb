class AddChallengeYearToMatch < ActiveRecord::Migration
  def change
    add_column :matches, :challenge_year, :integer
  end
end
