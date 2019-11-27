class TeamMailer < ActionMailer::Base

    def team_details_email(competition, team, qualifications, finals)
      puts ENV['MINDSTORM_EMAIL_LOGIN']
      puts ENV['MINDSTORM_EMAIL_PASSWORD']
      @team = team
      @qualifications = qualifications
      @finals = finals
      @competition = competition
      @r_count = 0
      @p_count = 0
      @c_count = 0
      @team.robot_scores.each do |score|
        @r_count += score.award_count
      end
      @team.project_scores.each do |score|
        @p_count += score.award_count
      end
      @team.corevalue_scores.each do |score|
        @c_count += score.award_count
      end

      cc_email = competition.from_email
      if team.asst_coach_email != nil && team.asst_coach_email != ''
        cc_email += ', ' + team.asst_coach_email
      end

      to_email_with_name = "#{team.coach} <#{team.coach_email}>"
      from_email_with_name = "#{competition.contact_name} <#{competition.from_email}>"
      mail(from: competition.from_email, cc: competition.from_email,
            reply_to: from_email_with_name,
            to: to_email_with_name,
            subject: "Your Team's Results at #{competition.full_name}")
    end
end
