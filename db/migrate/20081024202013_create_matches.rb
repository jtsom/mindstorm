class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|
      t.integer :match_number
      t.integer :score
      t.text    :results
      t.references :team
      t.timestamps
    end
  end

  def self.down
    drop_table :matches
  end
end
