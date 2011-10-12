class CreateCompetitions < ActiveRecord::Migration
  def self.up
    create_table :competitions do |t|
      t.string :name
      t.string :email
      t.string :password

      t.timestamps
    end
  end

  def self.down
    drop_table :competitions
  end
end
