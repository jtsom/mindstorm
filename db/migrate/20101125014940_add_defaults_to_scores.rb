class AddDefaultsToScores < ActiveRecord::Migration
  def self.up
    change_table :corevalue_scores do |t|
  		t.change_default :i_discovery, 0
  		t.change_default :i_team_spirit, 0
  		t.change_default :i_integration, 0
  		t.change_default :t_effectiveness, 0
  		t.change_default :t_efficiency, 0
  		t.change_default :t_initiative, 0
  		t.change_default :g_inclusion, 0
  		t.change_default :g_respect, 0
  		t.change_default :g_coopertition, 0	
  	end
  	change_table :project_scores do |t|
  		t.change_default :r_problemID, 0
  		t.change_default :r_source, 0
  		t.change_default :r_analysis, 0
  		t.change_default :r_review, 0
  		t.change_default :i_teamsolution, 0
  		t.change_default :i_innovation, 0
  		t.change_default :i_implementation, 0
  		t.change_default :p_preseffective, 0
  		t.change_default :p_creativity, 0
  		t.change_default :p_sharing, 0
  	end
  	change_table :robot_scores do |t|
  		t.change_default :m_durability, 0
  		t.change_default :m_efficiency, 0
  		t.change_default :m_mechanization, 0
  		t.change_default :p_quality, 0
  		t.change_default :p_efficiency, 0
  		t.change_default :p_automation, 0
  		t.change_default :i_designprocess, 0
  		t.change_default :i_strategy, 0
  		t.change_default :i_innovation, 0
  	end
  end

  def self.down
  end
end
