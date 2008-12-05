class Team < ActiveRecord::Base

    has_many :matches, :dependent => :destroy
    
    validates_uniqueness_of :fll_number, :message => "must be unique"
    validates_numericality_of :fll_number, :message => "is not a number"
    # validates_numericality_of :project_score, :message => "is not a number"
    # validates_numericality_of :technical_score, :message => "is not a number"
    
    def self.load_from_file(filename)
      self.destroy_all
      records = YAML::load(File.open(filename))
      records.each {|r| self.new(r).save}
    end
    
    def high_score
        matches.maximum(:score)|| 0
    end
    
    def total_score
        matches.sum(:score)
    end
    
    def average_score
      matches.average(:score) || 0
    end
    
end
