class Team < ActiveRecord::Base

    belongs_to :competition

    has_many :finals, :dependent => :destroy
    has_many :qualifications, :dependent => :destroy

    has_many :project_scores, :dependent => :destroy
    has_many :robot_scores, :dependent => :destroy
    has_many :corevalue_scores, :dependent => :destroy

    validates_uniqueness_of :fll_number, :scope => :competition_id, :message => "must be unique"
    validates_numericality_of :fll_number, :message => "is not a number"

    attr_accessor :performance_rank, :robot_rank, :total_score, :total_rank, :project_rank, :corevalue_rank, :champion_score, :champion_rank
    attr_accessor :robot_scores_rank
    attr_accessor :awards_count

    # Team.load_from_file(Rails.root.join('support','teams09.yml'))
    def self.load_from_file(filename)
      self.destroy_all
      records = YAML::load(File.open(filename))
      records.each {|r| self.new(r).save}
    end

    ####### ROBOT SCORING #######
    def mechanical_design
      robot_scores.average(:mechanical_design) || 0
    end

    def programming
      robot_scores.average(:programming) || 0
    end

    def innovation_strategy
      robot_scores.average(:innovation_strategy) || 0
    end

    def robot_scores_total
      robot_scores.average(:total_score) || 0
    end


    ####### PROJECT SCORING #######

     def research
       project_scores.average(:research) || 0
     end

     def innovative_solution
       project_scores.average(:innovative_solution) || 0
     end

     def presentation
       project_scores.average(:presentation) || 0
     end

     def project_scores_total
       project_scores.average(:total_score) || 0
     end


    ####### CORE VALUES SCORING #######

    def inspiration
      corevalue_scores.average(:inspiration) || 0
    end

    def teamwork
      corevalue_scores.average(:teamwork) || 0
    end

    def grac_prof
      corevalue_scores.average(:grac_prof) || 0
    end

    def corevalue_scores_total
      corevalue_scores.average(:total_score) || 0
    end

    #################################

    def high_score
        qualifications.maximum(:score)|| 0
    end

    # def second_highest_score
    #     qual = qualifications.sort_by { |a,b| b.score <=> a.score }
    #     qual.count > 1 ? qual[1].score : 0
    # end
    #
    # def third_highest_score
    #     qual = qualifications.sort { |a,b| b.score <=> a.score }
    #     qual.count > 2 ? qual[2].score : 0
    # end

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
