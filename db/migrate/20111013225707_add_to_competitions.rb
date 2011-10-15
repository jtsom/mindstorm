class AddToCompetitions < ActiveRecord::Migration
  def self.up
    add_column :competitions, :from_email, :string
    add_column :competitions, :full_name, :string
  end

  def self.down
    remove_column :competitions, :full_name
    remove_column :competitions, :from_email
  end
end