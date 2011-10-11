namespace :data do
	desc "Seed teams table with team data."
	task :seed => :environment do
		filename = Rails.root.join('support','teams.txt')
		
		data = File.open(filename).read.split("\n")
		data.each {|line|
			fields = line.split("\t")
			t = Team.new(:fll_number => fields[0].to_i, :team_name => fields[1], :school => fields[8], :town => fields[11], :coach => fields[2], :coach_email => fields[4], :asst_coach => fields[5], :asst_coach_email => fields[7], :state => fields[12] )
			puts t.team_name
			}
    end
end

# fll_number
# team_name
# school
# town
# coach
# coach email
# asst coach
# asst coach email
# state