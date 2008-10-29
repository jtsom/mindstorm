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
      $number_of_missions_scored += 1 if (mission.scoringCondition ? mission.scoringCondition.call(result) : (mission_score > 0))
      total += mission_score
    }
    # correct for fairness bonus  need to condition this with :KitUsed == :RCX
    # puts "result kit used is #{result[:KitUsed]}"
    # puts "raw score is #{raw_score}"
    # if (result[:KitUsed] == :RCX)
    #   scaled_score = scale(raw_score)
    # else 
    #   scaled_score = raw_score
    # end
    # bonus = scaled_score - raw_score
    # result[:bonus] = bonus
    # scaled_score
    
    raw_score
    
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
    @items.inject(true) {|valid, item|
      item.check(result) && valid
    } &&
    @checks.inject(true) {|valid, pair|
      c = pair[1].call(result)
      $errors << pair[0] if !c
      c && valid
    }
  end
end

class Item
  attr_reader :label, :description, :allowed_values, :scoring
  def initialize(label, description, allowed_values, scoring)
    @label = label
    @description = description
    @allowed_values = allowed_values
    @scoring = scoring
  end
  def to_s
    @description
  end
  def check(result)
    if @allowed_values.include?(result[@label])
      true
    else
      $errors << "#{@description} must be one of the following values: #{@allowed_values.join(",")}."
      false
    end
  end
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

def item(label, description, allowed_values, scoring_label)
  $item = Item.new(label, description, allowed_values, scoring_label)
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

YN = [1, 0]

################### The challenge definition -- READ THIS FIRST. It's the most important part of the project

challenge do
  mission "Bury Carbon Dioxide" do
    item :BuryCarbonDioxide, "# Gray carbon dioxide in underground area", 0..4, "5"
    score do |items|
      items[:BuryCarbonDioxide]*5
    end
  end
  
  mission "Construct Levees" do
    item :LeveeTouchingRed, "# Levee touching red beach", 0..8, "5"
    item :LeveeTouchingGreen, "# Levee touching green beach", 0..8, "4"
    score do |items|
      (items[:LeveeTouchingRed] * 5) + (items[:LeveeTouchingGreen] * 4)
    end
    check "Maximum of 8 levees" do |items|
        (items[:LeveeTouchingRed] + items[:LeveeTouchingRed]) <= 8
    end
  end
  
  mission "Test Levees" do
    item :TestLevees, "Wheel Hit or Miss Levees and not blocked?", YN, "15"
    score do |items|
      items[:TestLevees]*15
    end
  end
  
  mission "Raise Flood Barrier" do
    item :RaiseFloodBarrier, "Flood Barrier Raised?", YN, "15"
    score do |items|
      items[:RaiseFloodBarrier]*15
    end
  end
  
  mission "Elevate House" do
    item :ElevateHouse, "House Raised?", YN, "15"
    score do |items|
      items[:ElevateHouse]*25
    end
  end
  
  mission "Turn Off Lights" do
    item :TurnOffLights, "House Lights Turned Off?", YN, "20"
    score do |items|
      items[:TurnOffLights]*20
    end
  end
  
  mission "Open A Window" do
    item :OpenWindow, "House Window Opened?", YN, "25"
    score do |items|
      items[:OpenWindow]*20
    end
  end  
  
  mission "Get People Together" do
    item :RedAndWhiteInPinkArea, "# Red and White People in Pink Grid Area", 0..4, "10"
    item :BlueGrayInMtnsOrCity, "# Blue and Gray in Mountains or City", 0..4, "10"
    item :BlackWhiteInResearch, "# Black and White in Research Area", 0..4, "10"
    score do |items|
      ((items[:RedAndWhiteInPinkArea] >=3 ) ?  10 : 0) + 
      ((items[:BlueGrayInMtnsOrCity] >=3 ) ?  10 : 0) +
      ((items[:BlackWhiteInResearch] >=3 ) ? 10 : 0)
    end
  end
  
  mission "Find Agreement" do
    item :FindAgreement, "Arrows Pointing in the same direction?", YN, "40"
    score do |items|
      items[:FindAgreement] * 40
    end
  end
  
  mission "Fund Research" do
    item :MoneyInResearchArea, "Is the Yellow Money Ball in the Research area?", YN, "15"
    item :MoneyInUndergroundReservoir, "Is the Yellow Money Ball in the Underground reservoir area?", YN, "15"
    score do |items|
      items[:MoneyInResearchArea] * 15 + items[:MoneyInUndergroundReservoir] * 15
    end
    check "Money must be in either Research area or Underground Reservoir area" do |items|
      (items[:MoneyInResearchArea] + items[:MoneyInUndergroundReservoir]) <= 1
    end  
  end
  
  mission "Deliver Drilling Machine" do
    item :DrillingMachineDelivered, "Drilling Machine Delivered?", YN, "20"
    score do |items|
      items[:DrillingMachineDelivered]*20
    end
  end
  
  mission "Drilling Machine Assembly Raised" do
    item :DrillingMachineAssemblyRaised, "Drilling Machine Assembly Raised?", YN, "10"
    score do |items|
      items[:DrillingMachineAssemblyRaised]*10
    end
  end
  
  mission "Extract Ice Core" do
    item :ExtractIceCore, "Ice Core Extracted?", YN, "20"
    score do |items|
      items[:ExtractIceCore]*20
    end
  end

  mission "Ice Core Returned to Base" do
    item :IceCoreReturned, "Ice Core Retuned to Base?", YN, "10"
    score do |items|
      items[:IceCoreReturned]*10
    end
    check "Ice Core must be extracted before being returned" do |items|
      items[:ExtractIceCore]
    end
  end 
  
  mission "Deliver Buoy" do
    item :DeliverBuoy, "Buoy Delivered and Upright?", YN, "25"
    score do |items|
      items[:DeliverBuoy]*25
    end
  end
  
  mission "Insulate House" do
    item :InsulateHouse, "Insulation Delivered to House?", YN, "25"
    score do |items|
      items[:InsulateHouse]*10 
    end
  end
  
  mission "Ride Bicycle" do
    item :RideBicycle, "Bicycle Delivered to House?", YN, "10"
    score do |items|
      items[:RideBicycle]*10
    end
  end
  
  mission "Telecommunicate and Research" do
    item :Telecommunicate, "Laptop Computer Delivered to House?", YN, "10"
    score do |items|
      items[:Telecommunicate]*10
    end
  end
  
  mission "Study Wildlife" do
    item :StudyWildlifeBearUpright, "Bear Delivered to Research Area Upright?", YN, "15"
    item :StudyWildlifeBearSleeping, "Bear Delivered to Research Area Sleeping?", YN, "10"
    item :Snowmobile, "Snowmobile Delivered?", YN, "10"
    score do |items|
      items[:StudyWildlifeBearUpright]*15 + items[:StudyWildlifeBearSleeping]*10 + items[:Snowmobile]*10
    end
    check "Bear is either Upright or Sleeping" do |items|
      items[:StudyWildlifeBearUpright] + items[:StudyWildlifeBearSleeping] <= 1
    end
  end
  
  mission "Beat the Clock" do
    item :RobotInResearch, "Robot Finished in Research Area?", YN, "15"
    item :RobotInYellowGrid, "Robot Finished in Yellow Grid Area?", YN, "10"
    score do |items|
      items[:RobotInResearch]*15 + items[:RobotInYellowGrid]*10
    end
    check "Robot can only end up in the Research Area or Yellow Grid Area" do |items|
        items[:RobotInResearch] + items[:RobotInYellowGrid] <= 1
    end
  end
end

class Challenge
  def random_result

    result = {
      :BuryCarbonDioxide => rand(5),
      :LeveeTouchingRed => rand(9),
      :LeveeTouchingGreen => rand(9),
      :TestLevees => rand(2),
      :RaiseFloodBarrier => rand(2),
      :ElevateHouse => rand(2), 
      :TurnOffLights => rand(2), 
      :OpenWindow => rand(2),
      :RedAndWhiteInPinkArea => 4,
      :BlueGrayInMtnsOrCity => 5,
      :BlackWhiteInResearch => 2,
      :FindAgreement => rand(2), 
      :MoneyInResearchArea => rand(2), 
      :MoneyInUndergroundReservoir => rand(2), 
      :DrillingMachineDelivered => rand(2),
      :DrillingMachineAssemblyRaised => rand(2),
      :ExtractIceCore => rand(2),
      :IceCoreReturned => rand(2),
      :DeliverBuoy => rand(2), 
      :InsulateHouse => rand(2), 
      :RideBicycle => rand(2), 
      :Telecommunicate => rand(2),
      :StudyWildlifeBearUpright => rand(2),
      :StudyWildlifeBearSleeping => rand(2),
      :Snowmobile => rand(2),      
      :RobotInResearch => rand(2), 
      :RobotInYellowGrid => rand(2)
    }
  end
end