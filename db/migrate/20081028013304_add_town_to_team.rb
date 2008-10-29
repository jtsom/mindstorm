class AddTownToTeam < ActiveRecord::Migration
  def self.up
    add_column :teams, :town, :string
  end

  def self.down
    remove_column :teams, :town
  end
end
