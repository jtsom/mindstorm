class TeamMailer < ActionMailer::Base
    
    def team_details_email(competition, team, qualifications, finals)
      @team = team
      @qualifications = qualifications
      @finals = finals
      @competition = competition
      mail(:from => competition.full_name, :to => team.coach_email, :subject => "Your Team's Results at #{competition.full_name}")
    end
end
