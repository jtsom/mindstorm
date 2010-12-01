class Team < ActiveRecord::Base

    has_many :finals, :dependent => :destroy
    has_many :qualifications, :dependent => :destroy
    
    has_many :project_scores, :dependent => :destroy
    has_many :robot_scores, :dependent => :destroy
    has_many :corevalue_scores, :dependent => :destroy

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
