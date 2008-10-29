class AddSchoolNameToTeam < ActiveRecord::Migration
  def self.up
    add_column :teams, :school, :string
  end

  def self.down
    remove_column :teams, :school
  end
end
