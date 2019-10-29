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
    return 2019
  end

  def mission_name
    return "FIRST City Shaper"
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
    item :robot_inspection, "Robot and all of its equipment fit in the ‘Small Inspection Area’", "5", ["Yes", "No"], ["1", "0"]
    score do |items|
      0
    end
  end

  mission "M01 Elevated places" do
    item :supported_by_bridge, "Robot is Supported by the Bridge", "20", ["Yes", "No"], ["1", "0"]
    item :flags_raised, "one or more Flags are clearly raised any distance, only by the Robot", "15", ["0", "1", "2"], ["0", "1", "2"]
    score do |items|
      s = ((items[:supported_by_bridge].to_i) * 20) + ((items[:flags_raised].to_i) * 15)
      s += add_bonus(s, items[:robot_inspection] )
    end
  end

  mission "M02 Crane" do
    item :clearly_lowered, "Hooked Blue Unit is Clearly Lowered Any Distance", "20", ["Yes", "No"], ["1", "0"]
    item :independent_and_supported, "Hooked Blue Unit Independent and Supported by another Blue Unit", "15", ["Yes", "No"], ["1", "0"]
    item :completely_in_blue_circle, "Hooked Blue Unit Completely in Blue Circle", "15", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:clearly_lowered].to_i) * 20) + ((items[:independent_and_supported].to_i) * (items[:clearly_lowered].to_i) * 15) + (((items[:completely_in_blue_circle].to_i) * 15) * (items[:independent_and_supported].to_i) )
      s += add_bonus(s, items[:robot_inspection], 10 )
    end
  end

  mission "M03 Inspection Drone" do
    item :inspection_drone_supported, "Inspection Drone is Supported by axle (A) on the Bridge", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:inspection_drone_supported].to_i) * 10)
      s += add_bonus(s, items[:robot_inspection] )
    end
  end

  mission "M04 Design for Wildlife" do
    item :bat_supported_by_branch, "If the Bat is Supported by branch (B) on the Tree", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:bat_supported_by_branch].to_i) * 10)
      s += add_bonus(s, items[:robot_inspection] )
    end
  end

  mission "M05 Treehouse" do
    item :unit_supported_by_tree_large_branch, "Units supported by Tree's LARGE branch", "10", to_sa((0..16)), to_sa((0..16))
    item :unit_supported_by_tree_small_branch, "Units supported by Tree's SMALL branch", "15",to_sa((0..16)), to_sa((0..16))
    score do |items|
      s = ((items[:unit_supported_by_tree_large_branch].to_i) * 10) + ((items[:unit_supported_by_tree_small_branch].to_i) * 15)
      s += add_bonus(s, items[:robot_inspection] )
    end
    check "Maximum of 16 Units available for the Tree" do |items|
      (items[:unit_supported_by_tree_large_branch].to_i + items[:unit_supported_by_tree_small_branch].to_i) <= 16
    end
  end

  mission "M06 Traffic Jam" do
    item :traffic_jam_lifted, "Traffic Jam is Lifted", "10", ["Yes", "No"], ["1", "0"]
      score do |items|
        s = ((items[:traffic_jam_lifted].to_i) * 10)
        s += add_bonus(s, items[:robot_inspection] )
      end
  end

  mission "M07 Swing" do
    item :swing_released, "Swing is released",  "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:swing_released].to_i) * 20)
      s += add_bonus(s, items[:robot_inspection] )
    end
  end

  mission "M08 Elevator" do
    item :blue_car_down, "Blue Car Down", "15", ["Yes", "No"], ["1", "0"]
    item :balanced, "Balanced", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
       s = ((items[:blue_car_down].to_i) * 15) + ((items[:balanced].to_i) * 20)+ ((items[:pointer_tip_in_gray].to_i) * 18)
       s += add_bonus(s, items[:robot_inspection] )
    end
    check "Either Blue Car is Down or Elevator is Balanced!" do |items|
      (items[:blue_car_down].to_i + items[:balanced].to_i) <= 1
    end
  end

  mission "M09 Safety Factor" do
      item :blue_beams_down, "Blue Beams Knocked out", "10", to_sa((0..6)), to_sa((0..6))
      score do |items|
        s = ((items[:lift_strength_bar].to_i) * 10)
        s += add_bonus(s, items[:robot_inspection] )
      end
    end

  mission "M10 Steel Construction" do
    item :standing_and_independent, "Steel Structure standing and Independent and Supported by Hinges", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
       s = (items[:standing_and_independent].to_i * 20)
       s += add_bonus(s, items[:robot_inspection] )
    end
  end

  mission "M11 Innovative Architecture" do
    item :completely_in_circle, "Completely in Any Circle", "15", ["Yes", "No"], ["1", "0"]
    item :partly_in_circle, "Partly in Any Circle", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:completely_in_circle].to_i) * 15) + ((items[:partly_in_circle].to_i) * 10)
      s += add_bonus(s, items[:robot_inspection] )
    end
    check "Team Structure can either be Completely or Partly in any circle" do |items|
      (items[:completely_in_circle].to_i + items[:partly_in_circle].to_i) <= 1
    end
  end

  mission "M12 Design and Build" do
    item :circles_with_matching_units, "How many Circles have at least one color-matching Unit Completely In, and Flat Down on the Mat?", "10", to_sa((0..3)), to_sa((0..3))
    item :sum_stack_height, "If there are Independent Stacks at least partly in any Circles, what is the sum of all of their heights", "5", to_sa((0..28)), to_sa((0..28))
    score do |items|
      s = ((items[:circles_with_matching_units].to_i) * 10) + ((items[:sum_stack_height].to_i) * 5)
      s += add_bonus(s, items[:robot_inspection] )
    end
  end

  #check
  mission "M13 Sustainability Upgrades" do
    item :upgrades, "Upgrades Independent, and Supported only by a Stack, partly in any circle", "10", to_sa((0..3)), to_sa((0..3))
    score do |items|
      s = ((items[:upgrades].to_i) * 10)
      s += add_bonus(s, items[:robot_inspection] )
    end
  end

  mission "M14 Precision" do
    item :precision, "Precision Tokens left on Field", "60", ["6", "5", "4", "3", "2", "1", "0"], ["60", "45", "30", "20", "10", "5", "0"]

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
