# 
# teams_2007.rb
# 
# Use this script to extract team details from a csv file exported from excel.
# The file name is specified below. 
# Team information is written into a "yaml" format file.
#   "teams_2007.yml"
#
# To load the team descriptions for a tournament, use the application's Team.load_from_file() function.
# For example, to load the teams for the south tournament, run this from the main project directory:
#     %script/runner "Team.load_from_file 'support/teams_2007.yml'"
#
require 'yaml'

FILENAME = "teams.txt"

teams = []

data = File.open(FILENAME).read.split("\n")
data.each {|line|
  fields = line.split("\t")

    teams << {
      :fll_number => fields[0].to_i, :team_name => fields[1], :school => fields[8], :town => fields[11], :coach => fields[2], :coach_email => fields[4],
      :asst_coach => fields[5], :asst_coach_email => fields[7], :state => fields[12]
    }

}

puts teams.to_yaml

File.open("teams.yml", 'w') {|f|
  f.write teams.to_yaml
}


