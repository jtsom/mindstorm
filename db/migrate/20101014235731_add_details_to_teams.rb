class AddDetailsToTeams < ActiveRecord::Migration
  def self.up
    add_column :teams, :coach, :string
    add_column :teams, :coach_email, :string
    add_column :teams, :asst_coach, :string
    add_column :teams, :asst_coach_email, :string
    add_column :teams, :state, :string
  end

  def self.down
    remove_column :teams, :state
    remove_column :teams, :asst_coach_email
    remove_column :teams, :asst_coach
    remove_column :teams, :coach_email
    remove_column :teams, :coach
  end
end
