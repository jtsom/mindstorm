class CreateFinals < ActiveRecord::Migration
  def self.up
    create_table :finals do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :finals
  end
end
