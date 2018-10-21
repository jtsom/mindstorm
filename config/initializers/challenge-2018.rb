###################
# challenge.rb
#   FLL tournament application infrastructure
#   developed by Tim Burks / tim@neontology.com / 2006-10-01
#   This software is released under the MIT License. (http://www.opensource.org/licenses/mit-license.php)
###################

################### Implementation classes, skip this section on first reading


class Range
  def join(c)
    map{|x| x}.join(c)
  end
end

class Challenge
  attr_reader :missions, :raw_score, :scaled_score, :bonus
  def initialize
    @missions = []
  end

  def mission_year
    2018
  end

  def to_s
    @missions.inject("Missions") {|s, mission| s += "\n"+mission.to_s}
  end
  def addMission(mission)
    @missions << mission
  end
  def score(result)
    # compute raw score
    $number_of_missions_scored = 0
    raw_score = @missions.inject(0) {|total, mission|
      mission_score = mission.score(result)
      puts mission.description + " " + mission_score.to_s
      $number_of_missions_scored += 1 if (mission.scoringCondition ? mission.scoringCondition.call(result) : (mission_score > 0))
      total += mission_score
    }
    puts "raw score " + raw_score.to_s
    if raw_score < 0
      raw_score = 0
    end
    return raw_score
  end

  def check(result)
    $errors = []
    @missions.inject(true) {|valid, mission| mission.check(result) && valid}
  end
  def type_of(item)
    if @types == nil
      @types = {}
      @missions.each {|mission|
        mission.items.each {|item|
          allowed_values = item.allowed_values
          if allowed_values.class == Range
            @types[item.label] = :range
          elsif allowed_values.length == 2 and allowed_values[0] == 1 and allowed_values[1] == 0
            @types[item.label] = :boolean
          else
            @types[item.label] = :selection
          end
        }
      }
    end
    @types[item]
  end
end

class Mission
  attr_reader :description, :items
  attr_accessor :scoringFunction, :scoringCondition, :displayFunction
  def initialize(description)
    @description = description
    @items = []
    @checks = []
  end
  def to_s
    @items.inject(@description) {|s, item|
      s += "\n    " + item.to_s
    }
  end
  def addItem(item)
    @items << item
  end
  def addCheck(title, block)
    @checks << [title, block]
  end
  def score(result)
    @scoringFunction.call(result)
  end
  def check(result)
    # @items.inject(true) {|valid, item|
    #   item.check(result) && valid
    # } &&
    @checks.inject(true) {|valid, pair|
      c = pair[1].call(result)
      $errors << pair[0] if !c
      c && valid
    }
  end
end

class Item
  attr_reader :label, :description, :scoring, :labels, :values
  def initialize(label, description, scoring, labels, values)
    @label = label
    @description = description
    @scoring = scoring
    @labels = labels
    @values = values
  end
  def to_s
    @description
  end
  # def check(result)
  #   if @allowed_values.include?(result[@label])
  #     true
  #   else
  #     $errors << "#{@description} must be one of the following values: #{@allowed_values.join(",")}."
  #     false
  #   end
  # end
end

################### The DSL declarations, skip this section on first reading

def challenge
  $challenge = Challenge.new()
  yield
end

def mission(title)
  $mission = Mission.new(title)
  $challenge.addMission($mission)
  yield
end

def item(label, description, scoring_label, labels, values)
  $item = Item.new(label, description, scoring_label, labels, values)
  $mission.addItem $item
end

def score(&block)
  $mission.scoringFunction = block
end

def scoringCondition(&block)
  $mission.scoringCondition = block
end

def display(&block)
  $mission.displayFunction = block
end

def check(description, &block)
  $mission.addCheck(description, block)
end

YN = ["1", "0"]

################### The challenge definition -- READ THIS FIRST. It's the most important part of the project

challenge do

  mission "M01 Space Travel" do
    item :broken_pipe_in_base, "Broken Pipe is completely in Base?", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      (items[:broken_pipe_in_base].to_i) * 20
    end
  end

  mission "M02 Solar Panel Array" do
    item :big_water, "Big Water is on other team’s Field", "25", ["Yes", "No"], ["1", "0"]
    score do |items|
      (items[:big_water].to_i) * 25
    end
  end

  mission "M03 3D Printing" do
  item :pump_contact_with_mat, "Pump Addition has contact with the mat?", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:pump_contact_with_mat].to_i) * 20)
    end
  end

  mission "M04 Crater Crossing" do
    item :rain_out_of_cloud, "At least one Rain is out of the Rain Cloud?", "20", ["Yes", "No"], ["1", "0"]
      score do |items|
        ((items[:rain_out_of_cloud].to_i) * 20)
      end
    end

  mission "M05 Extraction" do
    item :lock_latch_dropped, "Lock latch is in dropped position?", "30", ["Yes", "No"], ["1", "0"]
      score do |items|
        ((items[:lock_latch_dropped].to_i) * 30)
      end
  end

  mission "M06 Space Station Modules" do
    item :big_water_ejected, "Big Water is ejected from Water Treatment model?", "20", ["Yes", "No"], ["1", "0"]
      score do |items|
        ((items[:big_water_ejected].to_i) * 20)
      end
  end

  mission "M07 Space Walk Emergency" do
    item :middle_layer_raised, "Middle layer is raised?",  "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:middle_layer_raised].to_i) * 20)
    end
  end

  mission "M08 Aerobic Exercise" do
    item :manholes_flipped, "Manhole Cover(s) are flipped over past vertical", "15", ["0", "1", "2"], ["0", "1", "2"]
    item :both_manholes_flipped, "Both Manhole Covers are flipped over in separate Tripod Target?", "30", ["Yes", "No"], ["1", "0"]
    score do |items|
       ((items[:manholes_flipped].to_i) * 15) + ((items[:both_manholes_flipped].to_i) * 30)
    end
  end

  mission "M09 Strength Exercise" do
      item :all_tripod_feet_touching, "All the Tripod’s feet are touching the mat?", "15", ["Yes", "No"], ["1", "0"]
      item :tripod_partial, "Tripod is partially in a Tripod Target?", "15", ["Yes", "No"], ["1", "0"]
      item :tripod_complete, "Tripod is completely in a Tripod Target?", "20", ["Yes", "No"], ["1", "0"]
      score do |items|
        ((items[:all_tripod_feet_touching].to_i) * 1) * ( ((items[:tripod_partial].to_i) * 15) + ((items[:tripod_complete].to_i) * 20) )
      end
      check "Tripods can only be PARTIALLY or COMPLETELY in Tripod Target" do |items|
        (items[:tripod_partial].to_i + items[:tripod_complete].to_i) <= 1
      end
    end

  mission "M10 Food Production" do
    item :new_pipe_installed, "New Pipe is installed where Broken Pipe was?", "0", ["Yes", "No"], ["1", "0"]
    item :new_pipe_mat_contact, "The New Pipe has full/flat contact with the mat?", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
       (items[:new_pipe_installed].to_i * 1) * (items[:new_pipe_mat_contact].to_i * 20)
    end
  end

  mission "M11 Escape Velocity" do
    item :new_pipe_mat_contact_11, "New Pipe has full/flat contact with the mat?", "0", ["Yes", "No"], ["1", "0"]
    item :new_pipe_partial, "This new pipe is partially in its target?", "15", ["Yes", "No"], ["1", "0"]
    item :new_pipe_complete, "This new pipe is completely in its target?", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:new_pipe_mat_contact_11].to_i) * 1) * (((items[:new_pipe_partial].to_i) * 15) + ((items[:new_pipe_complete].to_i) * 20))
    end
    check "New Pipe can only be PARTIALLY or COMPLETELY in its target" do |items|
      (items[:new_pipe_partial].to_i + items[:new_pipe_complete].to_i) <= 1
    end
  end

  mission "M12 Satellite Orbits" do
    item :sludge_touching_wood, "Sludge touching visible wood of a drawn garden box?", "30", ["Yes", "No"], ["1", "0"]
    score do |items|
       ((items[:sludge_touching_wood].to_i) * 30)
    end
  end

  #check
  mission "M13 Observatory" do
    item :flower_raised, "Flower is raised?", "30", ["Yes", "No"], ["1", "0"]
    item :rain_touching_purple, "At least one Rain is in the purple part?", "30", ["Yes", "No"], ["1", "0"]
    score do |items|
       ((items[:flower_raised].to_i) * 30) + ((items[:rain_touching_purple].to_i) * 30)
    end
  end

  mission "M14 Meteoroid Deflection" do
    item :water_well_partial, "Water Well contacting mat PARTIALLY inside target area?", "15", ["Yes", "No"], ["1", "0"]
    item :water_well_complete, "Water Well contacting mat COMPLETELY inside target area?", "25", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:water_well_partial].to_i) * 15) + ((items[:water_well_complete].to_i) * 25)
    end
    check "Water Well can only be PARTIALLY or COMPLETELY inside target area" do |items|
      (items[:water_well_partial].to_i + items[:water_well_complete].to_i) <= 1
    end
  end

  mission "M15 Lander Touch-Down" do
    item :fire_dropped, "Fire is dropped?", "25", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:fire_dropped].to_i) * 25)
    end
  end

  mission "P Penalties" do
    item :penalties, "Penalty discs in the southeast triangle area", "-3", ["0", "1", "2", "3", "4", "5", "6"], ["0", "1", "2", "3", "4", "5", "6"]

    score do |items|
       (items[:penalties].to_i) * -5
    end
  end
end
