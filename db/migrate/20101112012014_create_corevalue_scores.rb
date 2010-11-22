class CreateCorevalueScores < ActiveRecord::Migration
  def self.up
    create_table :corevalue_scores do |t|

      t.integer :i_discovery
      t.integer :i_team_spirit
      t.integer :i_integration
      t.text    :i_comments
      
      t.integer :t_effectiveness
      t.integer :t_efficiency
      t.integer :t_initiative
      t.text    :t_comments
      
      t.integer :g_inclusion
      t.integer :g_respect
      t.integer :g_coopertition
      t.text    :g_comments
      
      t.integer :total_score
      
      t.references :team
      t.timestamps
    end
  end

  def self.down
    drop_table :corevalue_scores
  end
end
