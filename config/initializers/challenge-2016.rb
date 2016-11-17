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
    2016
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

  mission "M01 Shark Shipment" do
    item :tank_and_shark_in_target, "Tank and Shark are completely in Target", "7/10", ["None", "T1", "T2"], ["None", "T1", "T2"]
    item :shark_touching_tank_only, "Shark touching only tank floor (NOT wall)?", "20", ["Yes", "No"], ["1", "0"]
    item :nothing_touched_shark, "Nothing touched the Shark except the tank?", "-", ["Yes", "No"], ["1", "0"]

    score do |items|
      s = 0
      if (items[:nothing_touched_shark] == "1")
        s = case items[:tank_and_shark_in_target].to_s
            when "None" then 0
            when "T1" then (7 + (items[:shark_touching_tank_only].to_i) * 20)
            when "T2" then (10 + (items[:shark_touching_tank_only].to_i) * 20)
            else 0
        end
      end
      s
    end
  end

  mission "M02 Service Dog Action" do

    item :warning_fence_down, "Warning Fence is down", "15", ["Yes", "No"], ["1", "0"]
    item :robot_crossed_fence, "Robot completely crossed fence", "0", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = 0
      if (items[:robot_crossed_fence].to_i) == 1
        s += ((items[:warning_fence_down].to_i) * 15)
      end
      s
    end
  end

  mission "M03 Animal Conservation" do
  item :pairs_of_identical_animals, "Pairs of Identical Animals completely on same side", "20", ["0", "1", "2", "3", "4", "5", "6"], ["0", "1", "2", "3", "4", "5", "6"]
    score do |items|
      ((items[:pairs_of_identical_animals].to_i) * 20)
    end
  end

  mission "M04 Feeding" do
    item :pieces_of_food, "Pieces of food completely in Animal Areas", "10", ["0", "1", "2", "3", "4", "5", "6", "7", "8"], ["0", "1", "2", "3", "4", "5", "6", "7", "8"]
    score do |items|
      ((items[:pieces_of_food].to_i) * 10)
    end
  end

  mission "M05 Biomimicry" do
    item :wall_supports_gecko, "Wall supports complete weight of White Gecko", "15", ["Yes", "No"], ["1", "0"]
    item :wall_supports_robot, "Wall supports complete weight of Robot", "32", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:wall_supports_gecko].to_i) * 15) + ((items[:wall_supports_robot].to_i) * 32)
    end
  end

  mission "M06 Milking Automation" do
    item :milk_and_manure, "Milk AND Manure have all rolled out?", "15", ["Yes", "No"], ["1", "0"]
    item :milk_only, "Milk has all rolled out, but NOT Manure?", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:milk_and_manure].to_i) * 15) + ((items[:milk_only].to_i) * 20)
    end

    check "Milk AND Manure OR Milk ONLY" do |items|
      (items[:milk_and_manure].to_i + items[:milk_only].to_i) <= 1
    end
  end

  mission "M07 Panda Release" do
    item :slider_opened, "Slider appears fully opened clockwise installed",  "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:slider_opened].to_i) * 10)
    end
  end

  mission "M08 Camera Recovery" do
    item :camera_in_base, "Camera is completely in Base?", "15", ["Yes", "No"], ["1", "0"]
    score do |items|
       ((items[:camera_in_base].to_i) * 15)
    end
  end

  mission "M09 Training and Research" do
      item :dog_trainer_in_research, "Dog, Trainer completely in Training/Research Area?", "12", ["Yes", "No"], ["1", "0"]
      item :zoologist_in_research, "Zoologist completely in Training/Research Area?", "15", ["Yes", "No"], ["1", "0"]
      item :manure_in_research, "Manure completely in Training/Research Area", "5", ["0", "1", "2", "3", "4", "5", "6", "7"], ["0", "1", "2", "3", "4", "5", "6", "7"]
      score do |items|
        ((items[:dog_trainer_in_research].to_i) * 12) + ((items[:zoologist_in_research].to_i) * 15) + ((items[:manure_in_research].to_i) * 5)
      end
    end

  mission "M10 Bee Keeping" do
    item :bee_no_honey, "Bee is on Beehive with NO Honey in Beehive?", "12", ["Yes", "No"], ["1", "0"]
    item :bee_honey_in_base, "Bee is on Beehive and Honey in Base?", "15", ["Yes", "No"], ["1", "0"]
    score do |items|
       (items[:bee_no_honey].to_i * 12) + (items[:bee_honey_in_base].to_i * 15)
    end
    check "No Honey in Beehive OR honey in Base" do |items|
      (items[:bee_no_honey].to_i + items[:bee_honey_in_base].to_i) <= 1
    end
  end

  mission "M11 Prosthesis" do
    item :prosthesis_not_held_by_ref, "Prosthesis fitted to Pet, NOT held by Ref?", "9", ["Yes", "No"], ["1", "0"]
    item :prostheses_in_farm, "Prosthesis fitted to Pet and completely in Farm?", "15", ["Yes", "No"], ["1", "0"]
    score do |items|
       ((items[:prosthesis_not_held_by_ref].to_i) * 9) + ((items[:prostheses_in_farm].to_i) * 15)
    end
    check "Prosthesis on pet and not held by ref OR completely in Farm" do |items|
      (items[:prosthesis_not_held_by_ref].to_i + items[:prostheses_in_farm].to_i) <= 1
    end
  end

  mission "M12 Seal In Base" do
    item :seal_in_base, "Seal is completely in Base, NOT broken?", "1", ["Yes", "No"], ["1", "0"]
    score do |items|
       ((items[:seal_in_base].to_i) * 1)
    end
  end

  #check
  mission "M13 Milk In Base" do
    item :three_milk_in_base, "All three Milk are completely in Base?", "1", ["Yes", "No"], ["1", "0"]
    score do |items|
       ((items[:three_milk_in_base].to_i) * 1)
    end
  end

  mission "M14 Milk On Ramp" do
    item :milk_on_ramp_option, "Select Best Option", "2/3/4", ["None", "A", "B", "C"], ["None", "A", "B", "C"]

    score do |items|
      s = 0
      if items[:milk_on_ramp_option] != "None"
        s = case items[:milk_on_ramp_option].to_s
        when "A" then 2
        when "B" then 3
        when "C" then 4
          else 0
        end
      end
      s
    end
  end

  mission "M15 All Samples" do
    item :all_manure_in_research, "All seven Manure Samples completely in Training/Research Area?", "5", ["Yes", "No"], ["1", "0"]

    score do |items|
      if items[:manure_in_research].to_i == 7
        items[:all_manure_in_research] == "1"
      end
       ((items[:all_manure_in_research].to_i)) * 5
    end
  end

  mission "P Penalties" do
    item :penalties, "Number of Manure Samples in the white triangle area", "-6", ["0", "1", "2", "3", "4", "5"], ["0", "1", "2", "3", "4", "5"]

    score do |items|
       (items[:penalties].to_i) * -6
    end
  end
end
