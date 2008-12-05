class AddTableToMatches < ActiveRecord::Migration
  def self.up
    add_column :matches, :table_number, :integer
  end

  def self.down
    remove_column :matches, :table_number
  end
end
