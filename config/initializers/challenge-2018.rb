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
    item :vehicle_payload_down_ramp, "Vehicle Payload independently rolled down ramp?", "22", ["Yes", "No"], ["1", "0"]
    item :supply_payload_down_ramp, "Supply Payload independently rolled down ramp?", "14", ["Yes", "No"], ["1", "0"]
    item :crew_payload_down_ramp, "Crew Payload independently rolled down ramp?", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:broken_pipe_in_base].to_i) * 22) + ((items[:supply_payload_down_ramp].to_i) * 14) + ((items[:crew_payload_down_ramp].to_i) * 10)
    end
  end

  mission "M02 Solar Panel Array" do
    item :both_angled_same_field, "Both Solar Panels are Angled toward the same Field", "22", ["Yes", "No"], ["1", "0"]
    item :yours_angled_other_field, "our Solar Panel is Angled toward the other team’s Field", "18", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:both_angled_same_field].to_i) * 22) + ((items[:yours_angled_other_field].to_i) * 18)
    end
  end

  mission "M03 3D Printing" do
    item :brick_ejected_in_planet, "The 2x4 Brick ejected and completely in the Northeast Planet Area", "22", ["Yes", "No"], ["1", "0"]
    item :brick_ejected_not_in_planet, "The 2x4 Brick ejected and not completely in the Northeast Planet Area?", "18", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:brick_ejected_in_planet].to_i) * 22) + ((items[:brick_ejected_not_in_planet].to_i) * 18)
    end
    check "2x4 Brick much either be IN planet area or not in planet area" do |items|
      (items[:brick_ejected_in_planet].to_i + items[:brick_ejected_not_in_planet].to_i) <= 1
    end
  end

  mission "M04 Crater Crossing" do
    item :robot_crossed_crater, "Robot has crossed crater?", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:robot_crossed_crater].to_i) * 20)
    end
  end

  mission "M05 Extraction" do
    item :four_core_samples_moved, "All four Core Samples so they are no longer touching the axle", "16", ["Yes", "No"], ["1", "0"]
    item :gas_core_sample_in_lander, "Gas Core Sample completely in the Lander’s Target Circle", "12", ["Yes", "No"], ["1", "0"]
    item :gas_core_sample_in_base, "Gas Core Sample completely in Base", "10", ["Yes", "No"], ["1", "0"]
    item :water_core_sample_in_food_chamber, "Water Core Sample supported only by the Food Growth Chamber", "8", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:four_core_samples_moved].to_i) * 16) + ((items[:gas_core_sample_in_lander].to_i) * 12) + ((items[:gas_core_sample_in_base].to_i) * 10) + ((items[:water_core_sample_in_food_chamber].to_i) * 8)
    end
    check "Gas Core Sample can either be in Lander Target Circle OR Base" do |items|
      (items[:gas_core_sample_in_lander].to_i + items[:gas_core_sample_in_base].to_i) <= 1
    end
  end

  mission "M06 Space Station Modules" do
    item :cone_module_in_base, "Big Water is ejected from Water Treatment model?", "16", ["Yes", "No"], ["1", "0"]
    item :tube_module_in_west_habitation, "Tube Module into the Habitation Hub port west side?", "16", ["Yes", "No"], ["1", "0"]
    item :dock_module_in_east_habitation, "Dock Module into the Habitation Hub port east side?", "14", ["Yes", "No"], ["1", "0"]
      score do |items|
        ((items[:cone_module_in_base].to_i) * 16) + ((items[:tube_module_in_west_habitation].to_i) * 16) + ((items[:dock_module_in_east_habitation].to_i) * 14)
      end
  end

  mission "M07 Space Walk Emergency" do
    item :gerhard_completely_in_airlock, "Gerhard Completely in Airlock?",  "22", ["Yes", "No"], ["1", "0"]
    item :gerhard_partially_in_airlock, "Gerhard Partially in Airlock",  "18", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:gerhard_completely_in_airlock].to_i) * 22) + ((items[:gerhard_partially_in_airlock].to_i) * 18)
    end
    check "Gerhard can be Completely or Partially in airlock, not both!" do |items|
      (items[:gerhard_completely_in_airlock].to_i + items[:gerhard_partially_in_airlock].to_i) <= 1
    end
  end

  mission "M08 Aerobic Exercise" do
    item :pointer_tip_in_orange, " Pointer tip completely in orange, or partly covering either of orange’s end-borders", "22", ["0", "1", "2"], ["0", "1", "2"]
    item :pointer_tip_completely_white, "Pointer tip completely in white?", "20", ["Yes", "No"], ["1", "0"]
    item :pointer_tip_in_gray, "Pointer tip completely in gray, or partly covering either of gray’s end-borders?", "18", ["Yes", "No"], ["1", "0"]
    score do |items|
       ((items[:pointer_tip_in_orange].to_i) * 22) + ((items[:pointer_tip_completely_white].to_i) * 20)+ ((items[:pointer_tip_in_gray].to_i) * 18)
    end
    check "Pointer Tip can only be in Orange, Grey or White!" do |items|
      (items[:pointer_tip_in_orange].to_i + items[:pointer_tip_completely_white].to_i) + items[:pointer_tip_in_gray].to_i) <= 1
    end
  end

  mission "M09 Strength Exercise" do
      item :lift_strength_bar, "Lift Strength Bar?", "16", ["Yes", "No"], ["1", "0"]
      score do |items|
        ((items[:lift_strength_bar].to_i) * 16)
      end
    end

  mission "M10 Food Production" do
    item :spin_food_growth_chamber, "Spin Food Growth Chamger?", "16", ["Yes", "No"], ["1", "0"]
    score do |items|
       (items[:new_pipe_installed].to_i * 16)
    end
  end

  mission "M11 Escape Velocity" do
    item :spacecraft_stays_up, "Spacecraft Stays Up?", "24", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:new_pipe_mat_contact_11].to_i) * 26)
    end
  end

  mission "M12 Satellite Orbits" do
    item :satellites_in_outer_orbit, "Satellites in Outer Orbit?", "8", ["0", "1", "2", "3"], ["0", "1", "2", "3"]
    score do |items|
       ((items[:sludge_touching_wood].to_i) * 8)
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
