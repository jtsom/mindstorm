class CreateQualifications < ActiveRecord::Migration
  def self.up
    create_table :qualifications do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :qualifications
  end
end
