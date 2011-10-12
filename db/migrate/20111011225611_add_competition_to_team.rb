class AddCompetitionToTeam < ActiveRecord::Migration
  def self.up
    add_column :teams, :competition_id, :integer
  end

  def self.down
    remove_column :teams, :competition_id
  end
end