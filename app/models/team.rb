class Team < ActiveRecord::Base

    has_many :finals, :dependent => :destroy
    has_many :qualifications, :dependent => :destroy
    
    has_one :project_score, :dependent => :destroy
    has_one :robot_score, :dependent => :destroy

    validates_uniqueness_of :fll_number, :message => "must be unique"
    validates_numericality_of :fll_number, :message => "is not a number"
    # validates_numericality_of :project_score, :message => "is not a number"
    # validates_numericality_of :technical_score, :message => "is not a number"
    
    # Team.load_from_file(Rails.root.join('support','teams09.yml'))  
    def self.load_from_file(filename)
      self.destroy_all
      records = YAML::load(File.open(filename))
      records.each {|r| self.new(r).save}
    end
    
    def teamwork_score
      ts = 0
      if robot_score
        ts = robot_score.kids_score || 0
      end
      if project_score
        ts += project_score.teamwork_score || 0
      end
      ts || 0
    end
    
    def total_robot_score
      if self.robot_score
        self.robot_score.total_score
      else
        0
      end
    end
    
    def total_project_score
      if self.project_score
        self.project_score.total_score
      else
        0
      end
    end
    
    def high_score
        matches.maximum(:score)|| 0
    end
    
    def total_qual_score
        qualifications.sum(:score)
    end
    
    def total_finals_score
        finals.sum(:score)
    end
    
    def average_qual_score
      qualifications.average(:score) || 0
    end
    
    def average_final_score
      finals.average(:score) || 0
    end
    
end
