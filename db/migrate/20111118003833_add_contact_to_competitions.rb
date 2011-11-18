class AddContactToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :contact_name, :string
  end

  def self.down
    remove_column :competitions, :contact_name
  end
end