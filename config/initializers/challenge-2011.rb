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
    2010
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
def corn_harvest_score(corn_in_base, corn_on_mat)
  if corn_in_base == 1
    9
  elsif corn_on_mat == 1
    5
  else
    0
  end
end

challenge do
  mission "Good Bacteria" do
    item :yellow_in_base, "Yellow bacteria in base (touch penalty)", 0..12, "6"
    score do |items|
      items[:yellow_in_base] * 6
    end
  end
  
  mission "Farm Fresh Produce" do
    item :truck_in_base, "Yellow truck in base?", YN, "9"
    score do |items|
      items[:truck_in_base] * 9
    end
  end
  
  mission "Pest Removal" do
    item :rats_in_base, "Rats In Base", 0..2, "15"
    score do |items|
       items[:rats_in_base] * 15
    end
  end

  mission "Pizza and Ice Cream" do
    item :pizza_icecream_in_base, "Pizza/ice cream in base", 0..2, "7"
    score do |items|
      items[:pizza_icecream_in_base] * 7
    end
  end
  
  mission "Fishing" do
    item :fish_in_base, "Fish in base", 0..3, "3"
    item :baby_fish_on_mark, "Baby fish on mark?", YN, ""
    score do |items|
      (items[:fish_in_base] * 3) * items[:baby_fish_on_mark]
    end
  end
  
  mission "Disinfect" do
    item :dispensers_empty, "Dispensers Empty", 0..3, "12/7"
    item :bacteria_outside_base, "Any bacteria outside base?", YN, ""
    score do |items|
      items[:dispensers_empty] * (items[:bacteria_outside_base] == 1 ? 7 : 12)
    end
  end
  
  mission "Corn Harvest" do
    item :corn_touching_mat, "Any corn touching mat?", YN, "5"
    item :corn_in_base, "Any corn in base?", YN, "9"
    score do |items|
      corn_harvest_score(items[:corn_in_base], items[:corn_touching_mat])
    end
  end
  
  mission "Pollution Reversal" do
    item :balls_touching_mat, "Balls touching mat", 0..2, "4"
    score do |items|
      items[:balls_touching_mat] * 4
    end
  end 
  
  mission "Refrigerated Ground Transport" do
    item :trailer_in_base, "Trailer in base?", YN, "12"
    item :trailer_touching_north_port, "Clean trailer touching north port?", YN, "20"
    item :fish_in_trailer, "Fish in trailer", 0..3, "6"
    score do |items|
      (items[:trailer_in_base] * 12) + (items[:trailer_touching_north_port] * 20) + ( ( (items[:trailer_touching_north_port] * items[:fish_in_trailer] ) * 6 ) * items[:baby_fish_on_mark] )
    end
    check "Trailer in base or touching north port, not both" do |items|
      (items[:trailer_in_base] + items[:trailer_touching_north_port]) <= 1
    end
  end  
  
  mission "Hand Washing Bacterial" do
    item :bacteria_in_sink, "Bacteria in sink", 0..60, "3"
    score do |items|
      (items[:bacteria_in_sink] * 3)
    end
  end
   
  mission "Hand Washing Viral" do
      item :one_to_eight_in_sink, "1 to 8 germs in sink?", YN, "6"
      item :nine_plus_in_sink, "9 or more germs in sink?", YN, "13"
      score do |items|
        (items[:one_to_eight_in_sink] * 6) + (items[:nine_plus_in_sink] * 13)
      end
      check "Only 1 to 8 or 9 or more germs in sink may be selected" do |items|
        (items[:one_to_eight_in_sink] + items[:nine_plus_in_sink]) <= 1
      end
    end
  
  mission "Storage Temperature" do
      item :low_temp_showing, "Thermometer spindle showing low red temp?", YN, "20"
      score do |items|
        items[:low_temp_showing] * 20
      end
    end
   
    mission "Cooking Time" do
      item :pointer_in_red_zone, "White pointer in the red zone?", YN, "14"
      score do |items|
        items[:pointer_in_red_zone] * 14
      end
    end

     mission "Groceries" do
       item :groceries_on_table, "Groceries on the table", 0..12, "2"
       score do |items|
         items[:groceries_on_table] * 2
       end
     end   
      
     mission "Distant Travel" do
       item :touching_east_wall, "Robot touching East wall?", YN, "9"
       score do |items|
         (items[:touching_east_wall] * 3)
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