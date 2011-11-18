class TeamMailer < ActionMailer::Base
    
    def team_details_email(competition, team, qualifications, finals)
      @team = team
      @qualifications = qualifications
      @finals = finals
      @competition = competition
      to_email_with_name = "#{team.coach} <#{team.coach_email}>"
      from_email_with_name = "#{competition.full_name} <#{competition.from_email}>"
      mail(:from => competition.from_email, :cc => competition.from_email, 
            :reply_to => from_email_with_name,
            :to => to_email_with_name,
            :subject => "Your Team's Results at #{competition.full_name}")
    end
end
