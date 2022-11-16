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
    return 2022
  end

  def mission_name
    return "FIRST SuperPowered"
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

  mission "M00 Equipment Inspection" do
    item :robot_inspection, "Robot and all of its equipment fit completely in one launch area", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      (items[:robot_inspection].to_i) * 20
    end
  end

  mission "M01 Innovation Project Model" do
    item :complete_project_model, "Innovation project model made of at least 2 white pieces; measures at least 4 'studs'; partly in circle", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      (items[:complete_project_model].to_i) * 10
    end
  end

  mission "M02 Oil Platform" do
    item :fuel_units_in_truck, "Fuel Units in truck", "5", to_sa((0..3)), to_sa((0..3))
    item :fuel_unit_over_station, "One fuel unit is in the fuel truck and the fuel truck is at least partly over the fueling station target", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:fuel_units_in_truck].to_i) * 5)
      s += ((items[:fuel_unit_over_station].to_i) * 10) if s > 0
    end
  end

  mission "M03 Energy Storage" do
    item :energy_units_in_bin, "Energy units completely in the energy storage bin, not touching team equipment", "10", ["0", "1", "2", "3+"], ["0","1", "2", "3"]
    item :energy_unit_removed_from_bin, "Energy unit is completely removed from the energy storage tray", "5", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:energy_units_in_bin].to_i) * 10) + ((items[:energy_unit_removed_from_bin].to_i) * 5)
    end
  end

  mission "M04 Solar Farm" do
    item :solar_energy_units_removed, "Energy units completely removed from its starting circle", "5", to_sa((0..3)), to_sa((0..3))
    score do |items|
    	s = ((items[:solar_energy_units_removed].to_i) * 5)
    	s += (items[:solar_energy_units_removed].to_i) == 3 ? 5 : 0
    end
  end

  mission "M05 Smart Grid" do
    item :your_field_connector_raised, "Your field's orange connector is completely raised, smart grid model not touching team equipment", "20", ["Yes", "No"], ["1", "0"]
    item :other_field_connector_raised, "Both teams' orange connectors are completely raised", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:your_field_connector_raised].to_i) * 20)
      s += ((items[:your_field_connector_raised].to_i) * (items[:other_field_connector_raised].to_i)) * 10
    end
  end

  mission "M06 Hybrid Car" do
    item :hybrid_car_not_touching_ramp, "Hybrid car is no longer touching the ramp", "10", ["Yes", "No"], ["1", "0"]
    item :hybrid_unit_in_car, "Hybrid unit is in the hybrid car", "10", ["Yes", "No"], ["1", "0"]
	  score do |items|
		  ((items[:hybrid_car_not_touching_ramp].to_i) * 10) + ((items[:hybrid_unit_in_car].to_i) * 10)
	  end

  end

  mission "M07 Wind Turbine" do
    item :energy_units_not_touching_turbine, "Energy units no longer touching the wind turbine",  "10", to_sa((0..3)), to_sa((0..3))
    score do |items|
      ((items[:energy_units_not_touching_turbine].to_i) * 10)
    end
  end

  mission "M08 Watch Television" do
    item :television_completely_raised, "Television is completely raised, model is not touching team equipment", "10", ["Yes", "No"], ["1", "0"]
    item :energy_unit_in_television, "Energy unit is completely in the green television slot, energy unit is not touching team equipment", "10", ["Yes", "No"], ["1", "0"]

    score do |items|
       ((items[:television_completely_raised].to_i) * 10) + ((items[:energy_unit_in_television].to_i) * 10)
    end
  end

  mission "M09 Dinosaur Toy" do
    item :dinosaur_toy_in_left_home, "Dinosaur toy is completely in the left home area", "10", ["Yes", "No"], ["1", "0"]
    item :dinosaur_toy_with_energy_unit, "Dinosaur toy lid is completely closed WITH energy unit inside", "10", ["Yes", "No"], ["1", "0"]
    item :dinosaur_toy_with_battery, "Dinosaur toy lid is completely closed WITH rechargeable battery inside", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = (items[:dinosaur_toy_in_left_home].to_i * 10)
      s += (((items[:dinosaur_toy_with_energy_unit].to_i * 10) + (items[:dinosaur_toy_with_battery].to_i * 20)))
    end
    check "Dinosaur Toy can only have EITHER an ENERGY UNIT or RECHARGEABLE BATTERY" do |items|
      (items[:dinosaur_toy_with_energy_unit].to_i + items[:dinosaur_toy_with_battery].to_i) <= 1
    end
  end

  mission "M10 Power Plant" do
    item :energy_units_not_touching_powerplant, "Energy units no longer touching the power plant", "5", to_sa((0..3)), to_sa((0..3))
    score do |items|
     s = ((items[:energy_units_not_touching_powerplant].to_i) * 5)
     s += items[:energy_units_not_touching_powerplant].to_i == 3 ? 10 : 0
    end

  end

  mission "M11 Hydroelectric Dam" do
    item :energy_unit_not_touching_dam, "Energy unit is no longer touching the hydroelectric dam", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:energy_unit_not_touching_dam].to_i) * 10)
    end
  end

  mission "M12 Water Reservoir" do
    item :water_units_in_reservoir, "Looped water units completely in the water reservoir, touching the mat, not touching team equipment", "5", to_sa((0..3)), to_sa((0..3))
    item :water_units_on_hook, "Looped water units placed on a single red hook (scored per hook), not touching team equipment", "10", to_sa((0..2)), to_sa((0..2))
    score do |items|
      s = ((items[:water_units_in_reservoir].to_i) * 5) + ((items[:water_units_on_hook].to_i) * 10)
    end
    check "Maximum of 3 LOOPED WATER UNITS" do |items|
      (items[:water_units_in_reservoir].to_i + items[:water_units_on_hook].to_i) <= 3
    end
  end

  mission "M13 Power-To-X" do
    item :energy_units_in_plant, "Energy units completely in the hydrogen plant target area", "5", ["0", "1", "2", "3+"], ["0","1", "2", "3"]
    score do |items|
      ((items[:energy_units_in_plant].to_i) * 5)
    end
  end

  mission "M14 Toy Factory" do
    item :energy_units_in_toy_factory, "Energy units at least partly in the slot in the back of the toy factory (or in the red hopper), not touching team equipment", "5", to_sa((0..3)), to_sa((0..3))
    item :mini_toy_released, "Mini dinosaur toy has been released", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:energy_units_in_toy_factory].to_i) * 5) + ((items[:mini_toy_released].to_i) * 10)
    end
  end

  mission "M15 Rechargable Battery" do
    item :energy_units_in_battery_area, "energy unit is completely in the rechargeable battery target area, not touching team equipment", "5", to_sa((0..3)), to_sa((0..3))
    score do |items|
      s = ((items[:energy_units_in_battery_area].to_i) * 5)
    end
  end

  mission "M16 Precision" do
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
