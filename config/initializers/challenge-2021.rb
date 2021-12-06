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
    return 2021
  end

  def mission_name
    return "FIRST Cargo Connect"
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

def to_sa(values)
  values.to_a.map { |x| x.to_s }
end

YN = ["1", "0"]

################### The challenge definition -- READ THIS FIRST. It's the most important part of the project

def add_bonus(score, inspect_value, bonus_value = 5)
  if score > 0 && inspect_value == '1'
    return (bonus_value)
  end
  return 0
end

challenge do

  mission "M00 Inspection" do
    item :robot_inspection, "Robot and all of its equipment fit in the 'Small Inspection Area'", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      (items[:robot_inspection].to_i) * 20
    end
  end

  mission "M01 Innovation Project Model" do
    item :complete_project_model, "Innovation project model made of at least 2 white pieces; measures at least 4 'studs'; touching circle", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      (items[:complete_project_model].to_i) * 20
    end
  end

  mission "M02 Unused Capacity" do
    item :closed_partly_full, "Hinged Container closed and Partly Full", "20", ["Yes", "No"], ["1", "0"]
    item :closed_completely_full, "Hinged Container closed and Completely Full", "30", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:closed_partly_full].to_i) * 20) + ((items[:closed_completely_full].to_i) * 30)
    end
    check "Closed Hinged Container can be either PARTIALLY full or COMPLETELY full." do |items|
      (items[:closed_partly_full].to_i + items[:closed_completely_full].to_i) <= 1
    end
  end

  mission "M03 Unload Cargo Plane" do
    item :cargo_plane_prepared, "Cargo plane door is completely down", "20", ["Yes", "No"], ["1", "0"]
    item :cargo_plane_unloaded, "Cargo is completely separate from plane", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:cargo_plane_prepared].to_i) * 20) + ((items[:cargo_plane_unloaded].to_i) * 10)
    end
  end

  mission "M04 Transportation Journey" do
    item :truck_reached_destination, "Truck has reached it's destination, completely past it's blue line", "10", ["Yes", "No"], ["1", "0"]
	item :airplane_reached_destination, "Airplane has reached it's destination, completely past it's blue line", "10", ["Yes", "No"], ["1", "0"]

    score do |items|
    	s = ((items[:truck_reached_destination].to_i) * 10) + ((items[:airplane_reached_destination].to_i) * 10)
    	s += ((items[:truck_reached_destination].to_i) * (items[:airplane_reached_destination].to_i)) * 10
    end
  end

  mission "M05 Switch Engine" do
    item :engine_switched_to_electric, "Engine has been switched from diesel to electric", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:engine_switched_to_electric].to_i) * 20)
    end
  end

  mission "M06 Accident Avoidance" do
    item :yellow_panel_not_knocked_down, "Robot parked over blue accident-avoidance line, yellow panel NOT KNOCKED DOWN And black frame is upright", "20", ["Yes", "No"], ["1", "0"]
    item :yellow_panel_knocked_down, "Robot parked over blue accident-avoidance line, yellow panel KNOCKED DOWN And black frame is upright", "30", ["Yes", "No"], ["1", "0"]
	  score do |items|
		((items[:yellow_panel_not_knocked_down].to_i) * 20) + ((items[:yellow_panel_knocked_down].to_i) * 30)
	  end
      check "Yellow panel cannot be both knocked down and NOT knocked down!" do |items|
        (items[:yellow_panel_not_knocked_down].to_i + items[:yellow_panel_knocked_down].to_i) <= 1
      end
  end

  mission "M07 Unload Cargo Ship" do
    item :container_not_touching_ship, "Container no longer touching cargo ship's east deck",  "20", ["Yes", "No"], ["1", "0"]
    item :container_touching_ship, "Container completely east of cargo ship's east deck",  "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:container_not_touching_ship].to_i) * 20) + ((items[:container_touching_ship].to_i) * 10)
    end
  end

  mission "M08 Air Drop" do
    item :food_packet_separted_from_helicopter, "Food Packet separated from helicopter", "20", ["Yes", "No"], ["1", "0"]
    item :food_packet_separted_from_other_field, "Food Packet separated from other field's helicopter, and in your field's circle", "10", ["Yes", "No"], ["1", "0"]
    item :both_teams_separated_food_package, "Both teams have separated their food package from their helicopter", "10", ["Yes", "No"], ["1", "0"]

    score do |items|
       ((items[:food_packet_separted_from_helicopter].to_i) * 20) + ((items[:food_packet_separted_from_other_field].to_i) * 10)+ ((items[:both_teams_separated_food_package].to_i) * 10)
    end
  end

  mission "M09 Train Tracks" do
      item :train_track_repaired, "Train track is repaired", "20", ["Yes", "No"], ["1", "0"]
      item :train_reached_destination, "Train has reached it's destination", "20", ["Yes", "No"], ["1", "0"]
      score do |items|
        ((items[:train_track_repaired].to_i) * 20) + ((items[:train_reached_destination].to_i) * 20)
      end
    end

  mission "M10 Sorting Center" do
    item :containers_sorted, "Containers have been sorted so only light orange container remains completely in blue box.", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
    (items[:containers_sorted].to_i * 20)
    end
  end

  mission "M11 Home Delivery" do
    item :package_delivered_partly_on_doorstep, "Package delivered and PARTLY on doorstep", "20", ["Yes", "No"], ["1", "0"]
    item :package_delivered_fully_on_doorstep, "Package delivered and COMPLETELY on doorstep", "30", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:package_delivered_partly_on_doorstep].to_i) * 20) + ((items[:package_delivered_fully_on_doorstep].to_i) * 30)
    end
    check "Package can be either PARTLY or COMPLETELY on doorstep" do |items|
      (items[:package_delivered_partly_on_doorstep].to_i + items[:package_delivered_fully_on_doorstep].to_i) <= 1
    end
  end

  mission "M12 Large Delivery" do
    item :turbine_blade_touching_mat, "Turbine blade touching blue holder and the mat?", "20", ["Yes", "No"], ["1", "0"]
    item :turbine_blade_not_touching_mat, "Turbine blade touching blue holder and nothing else?", "30", ["Yes", "No"], ["1", "0"]
    item :chicken_upright_partly_in_circle, "Chicken statue upright and partly in circle?", "5", ["Yes", "No"], ["1", "0"]
    item :chicken_upright_fully_in_circle, "Chicken statue upright and fully in circle?", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:turbine_blade_touching_mat].to_i) * 20) + ((items[:turbine_blade_not_touching_mat].to_i) * 30)
      s += ((items[:chicken_upright_partly_in_circle].to_i) * 5) + ((items[:chicken_upright_fully_in_circle].to_i) * 10)
    end
    check "Turbine blade can only be touching or not touching mat OR Chicken can only be FULLY or PARTLY in circle" do |items|
        ((items[:turbine_blade_touching_mat].to_i + items[:turbine_blade_not_touching_mat].to_i) <= 1) && ((items[:chicken_upright_partly_in_circle].to_i + items[:chicken_upright_fully_in_circle].to_i) <= 1)
    end
  end

  mission "M13 Platooning Trucks" do
    item :trucks_latched_together, "Both trucks latched together completely outside of home", "10", ["Yes", "No"], ["1", "0"]
    item :trucks_latched_to_bridge, "A truck is latched to a bridge", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:trucks_latched_together].to_i) * 10) + ((items[:trucks_latched_to_bridge].to_i) * 10)
      s += ((items[:trucks_latched_together].to_i) * (items[:trucks_latched_to_bridge].to_i)) * 10
    end
  end

  mission "M14 Bridge" do
    item :bridge_deck_lowered, "Bridge deck(s) lowered and rest on their center support", "10", to_sa((0..2)), to_sa((0..2))
    score do |items|
      ((items[:bridge_deck_lowered].to_i) * 10)
    end
  end

  mission "M15 Load Cargo" do
    item :containers_on_trucks, "Containers on and touching only platooning trucks", "10", to_sa((0..2)), to_sa((0..2))
    item :containers_on_train, "Containers on and touching only the train", "20", to_sa((0..2)), to_sa((0..2))
    item :containers_on_cargo_ship, "Containers on and touching only cargo ship's west deck", "30", to_sa((0..2)), to_sa((0..2))
    score do |items|
      s = ((items[:containers_on_trucks].to_i) * 10) + ((items[:containers_on_train].to_i) * 20) + ((items[:containers_on_cargo_ship].to_i) * 30)
    end
  end

  mission "M16 CARGO CONNECT℠" do
    item :containers_partly_any_circle, "Containers PARTLY in any circle", "5", to_sa((0..8)), to_sa((0..8))
    item :containers_fully_any_circle, "Containers COMPLETELY in any circle", "10", to_sa((0..8)), to_sa((0..8))
    item :blue_container_in_blue_circle, "Blue (not hinged) container completely in BLUE circle", "20", ["Yes", "No"], ["1", "0"]
    item :green_container_in_green_circle, "Lime Green container completely in GREEN circle", "20", ["Yes", "No"], ["1", "0"]
    item :circles_with_containers, "Circles with at least one container completely in them.", "10", to_sa((0..6)), to_sa((0..6))
    score do |items|
      s = ((items[:containers_partly_any_circle].to_i) * 5) + ((items[:containers_fully_any_circle].to_i) * 10) + ((items[:blue_container_in_blue_circle].to_i) * 20)
      s += ((items[:green_container_in_green_circle].to_i) * 20) + ((items[:circles_with_containers].to_i) * 10)
    end
  end

  mission "M17 Precision" do
    item :precision, "Precision Tokens left on Field", "50", ["6", "5", "4", "3", "2", "1", "0"], ["50", "50", "35", "25", "15", "10", "0"]

    score do |items|
      items[:precision].to_i
      # case (items[:precision].to_i)
      #   when 6
      #     60
      #   when 5
      #     45
      #   when 4
      #     30
      #   when 3
      #     20
      #   when 2
      #     10
      #   when 1
      #     5
      #   when 0
      #   0
      # end
    end
  end
end
