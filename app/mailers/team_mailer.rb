class TeamMailer < ActionMailer::Base
    default from: "john@shrewsburyrobotics.org"
    
    def team_details_email(team, qualifications, finals)
      @team = team
      @qualifications = qualifications
      @finals = finals
      mail(:to => team.coach_email, :subject => "Your Team's Results at Mindstorm Mayhem")
    end
end
