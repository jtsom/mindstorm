###################
# challenge.rb
#   FLL tournament application infrastructure
#   developed by Tim Burks / tim@neontology.com / 2006-10-01
#   This software is released under the MIT License. (http://www.opensource.org/licenses/mit-license.php)
###################

################### Implementation classes, skip this section on first reading

puts "***** here *****"

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
  mission "Gain Access To Places" do
    item :TargetSpot, "Robot Touching Target Spot?", YN, "25"
	item :YellowBridgeDeck, "Robot Touching Yellow Bridge Deck?", YN, "20"
	item :RedBridgeDeck, "Robot Touching Red Bridge Deck?", YN, "25"
    score do |items|
      (items[:TargetSpot] * 25) + (items[:YellowBridgeDeck] * 20) + (items[:RedBridgeDeck] * 25)
    end
	check "Robot can only be touching Target Spot, Yellow, or Red Bridge Deck" do |items|
      (items[:TargetSpot] + items[:YellowBridgeDeck] + items[:RedBridgeDeck]) <= 1
    end 
  end
  
  # Need max number of access markers and loops
  mission "Gain Access To Things" do
    item :AccessMarkers, "# Access Markers Down", 0..4, "25"
    item :LoopsInBase, "# Loops In Base", 0..11, "10"
    score do |items|
      (items[:AccessMarkers] * 25) + (items[:LoopsInBase] * 10)
    end
  end
  
  mission "Avoid Impacts" do
    item :WarningBeacons, "# Warning Beacons Upright", 0..8, "10"
	  item :SensorWallsAvoidance, "# Sensor Walls Upright", 0..4, "10"
    score do |items|
      (items[:WarningBeacons] * 10) + ( [ items[:SensorWallsAvoidance], items[:AccessMarkers] ].min * 10)
	  #need rules for walls + beacons + Sensor Walls Impact
    end
  # check "All Sensor Walls are Down, but Survive Impacts/All Sensor walls Down is NO" do |items|
  #   if items[:SensorWallsAvoidance] == 0 
  #     if items[:SensorWallsImpact] == 0
  #       false
  #     else
  #       true
  #     end
  #   else
  #     true
  #   end
  # end
  end
  
  mission "Survive Impacts" do
    item :SensorWallsImpact, "All Sensor Walls Down?", YN, "40"
	item :VehicleImpactTest, "Vehicle Not touching Red Pin", YN, "20"
	item :SinglePassenger, "Single Passenger In Robot?", YN, "15"
	item :MultiplePassenger, "Multiple Passengers Delivered?", YN, "10"
    score do |items|
      (items[:SensorWallsImpact] * 40) + (items[:VehicleImpactTest] * 20) + (items[:SinglePassenger] * 15) + (items[:MultiplePassenger] * 10)
    end
	check "Survive Impacts/All sensor walls are down = YES, but # Upright Sensor Walls Not Zero" do |items|
		if items[:SensorWallsImpact] == 1
			if items[:SensorWallsAvoidance] == 0
				true
			else
				false
			end
		else
			true
		end
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