class Team < ActiveRecord::Base

    has_many :matches
    
    validates_uniqueness_of :fll_number, :message => "must be unique"
    validates_numericality_of :fll_number, :message => "is not a number"
    
    def self.load_from_file(filename)
      self.destroy_all
      records = YAML::load(File.open(filename))
      records.each {|r| self.new(r).save}
    end
    
    def high_score
      if matches.length > 0
        matches.maximum(:score)
      else
        0
      end
    end
    
end
