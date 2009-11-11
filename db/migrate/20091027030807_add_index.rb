class AddIndex < ActiveRecord::Migration
  def self.up
    add_index :matches, :type
  end

  def self.down
    remove_index :matches, :type
  end
end
