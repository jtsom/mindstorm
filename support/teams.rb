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

FILENAME = "teams09.txt"

teams = []

data = File.open(FILENAME).read.split("\r")
data.each {|line|
  fields = line.split("\t")

    teams << {
      :fll_number => fields[0].to_i, :team_name => fields[1], :school => fields[2], :town => (fields[3] + ", " + fields[4])
    }

}

puts teams.to_yaml

File.open("teams09.yml", 'w') {|f|
  f.write teams.to_yaml
}


