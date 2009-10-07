class AddTypeToMatches < ActiveRecord::Migration
  def self.up
    add_column :matches, :type, :string
  end

  def self.down
    remove_column :matches, :type
  end
end
