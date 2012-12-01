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
def ball_game_score(balls_on_rack, own_color)
  if balls_on_rack == 7
    70
  else
    (balls_on_rack * 10) + (own_color * 60)
  end
end

def score_cardio(reading)
  j = '{"9-0":"118", "8-5":"117", "8-4":"116", "8-3":"115", "8-2":"114", "8-1":"113", "8-0":"112", "7-5":"111", "7-4":"110", "7-3":"109", "7-2":"108", "7-1":"107", "7-0":"106", "6-5":"103", "6-4":"100", "6-3":"97", "6-2":"64", "6-1":"61", "6-0":"78", "5-5":"75", "5-4":"82", "5-3":"69", "5-2":"66", "5-1":"63", "5-0":"60", "4-5":"55", "4-4":"50", "4-3":"45", "4-2":"50", "4-1":"35", "4-0":"30", "3-5":"25", "3-4":"20", "3-3":"15", "3-2":"10", "3-1":"5", "3-0":"0", "2-5":"-5", "2-4":"-10", "2-3":"-15", "2-2":"-20", "2-1":"-25", "2-0":"-30", "1-5":"-35", "1-4":"-40", "1-3":"-45", "1-2":"-50", "1-1":"-55", "1-0":"-60"}'
  hash = JSON.parse(j)

  value = hash[reading]
  if value != nil
    value.to_i
  else
    0
  end
end

def validate_cardio(reading)
  j = '{"9-0":"118", "8-5":"117", "8-4":"116", "8-3":"115", "8-2":"114", "8-1":"113", "8-0":"112", "7-5":"111", "7-4":"110", "7-3":"109", "7-2":"108", "7-1":"107", "7-0":"106", "6-5":"103", "6-4":"100", "6-3":"97", "6-2":"64", "6-1":"61", "6-0":"78", "5-5":"75", "5-4":"82", "5-3":"69", "5-2":"66", "5-1":"63", "5-0":"60", "4-5":"55", "4-4":"50", "4-3":"45", "4-2":"50", "4-1":"35", "4-0":"30", "3-5":"25", "3-4":"20", "3-3":"15", "3-2":"10", "3-1":"5", "3-0":"0", "2-5":"-5", "2-4":"-10", "2-3":"-15", "2-2":"-20", "2-1":"-25", "2-0":"-30", "1-5":"-35", "1-4":"-40", "1-3":"-45", "1-2":"-50", "1-1":"-55", "1-0":"-60"}'
  hash = JSON.parse(j)

  value = hash[reading]
  
end

challenge do

  mission "Flexibility" do
      item :yellow_loops_in_base, "Yellow loops in base", 0..2, "20"
      score do |items|
        (items[:yellow_loops_in_base] * 20)
      end
    end
  
  mission "Medicine" do

    item :green_bottle_in_base, "Green bottle in base?", YN, "25"
    score do |items|
      items[:green_bottle_in_base] * 25
    end
  end

  mission "Service Animals" do

    item :dog_in_base, "Dog in base?", YN, "20"
    score do |items|
       items[:dog_in_base] * 15
    end
  end

  mission "Wood Working" do

    item :chair_in_base, "Chair fixed and in base?", YN, "15"
    item :chair_under_table, "Chair fixed and under table?", YN, "25"
    score do |items|
      (items[:chair_in_base] * 15) + (items[:chair_under_table] * 25)
    end
    check "Chair can only be in base or under table" do |items|
      (items[:chair_in_base] + items[:chair_under_table]) <= 1
    end
  end

  mission "Video Call" do
    item :flags_raised, "Flags Raised", 0..2, "25"
    score do |items|
      items[:flags_raised] * 25
    end
  end

  mission "Quilting" do
    item :orange_touching_quilts, "Orange squares touching quilt", 0..2, "30"
    item :blue_touching_quilts, "Blue squares touching quilt", 0..2, "15"
    score do |items|
      (items[:orange_touching_quilts] * 30) + (items[:blue_touching_quilts] * 15)
    end
  end 

  mission "Similarity Recognition<br />and Cooperation" do
      item :pointer_aligned, "Pointer aligned with other team?", YN, "45"
      score do |items|
        items[:pointer_aligned] * 45
      end
    end

  mission "Ball Game" do
       item :balls_on_rack, "Balls on the rack", 0..7, "10"
       item :own_in_center, "Own color in center", YN, "60"
       score do |items|
         ball_game_score(items[:balls_on_rack], items[:own_in_center])
       end
     end 

  mission "Gardening" do
    item :plants_touching_mat, "Plants touching garden?", YN, "25"
    score do |items|
      items[:plants_touching_mat] * 25
    end
  end  

  mission "Stove" do
    item :black_burners, "All 4 burners black?", YN, "25"
    score do |items|
      items[:black_burners] * 25
    end
  end  

  mission "Bowling" do
    item :pins_knocked_down, "Pins knocked down", 0..6, "7"
    score do |items|
      if items[:pins_knocked_down] < 7
        items[:pins_knocked_down] * 7
      else
        60
      end
    end
  end

  mission "Transitions" do
      item :robot_on_tilted_center, "Robot on tilted center platform?", YN, "45"
      item :robot_on_balanced_center, "Robot on balanced center platform?", YN, "65"
      score do |items|
        (items[:robot_on_tilted_center] * 20) + (items[:robot_on_balanced_center] * 65)
      end
      check "Robot can only be balanced or tilted" do |items|
        (items[:robot_on_tilted_center] + items[:robot_on_balanced_center]) <= 1
      end
    end  

  mission "Strength Exercise" do
    item :weight_low, "Weight in low position", YN, "15"
    item :weight_high, "Weight in high position", YN, "25"
    score do |items|
      (items[:weight_low] * 15) + (items[:weight_high] * 25)
    end
    check "Weight can be in High or Low position only" do |items|
      (items[:weight_low] + items[:weight_high]) <= 1
    end
  end

  mission "Cardiovascular Exercise" do
    item :high_number, "High number of wheel", 1..9, "*"
    item :low_number, "Low number of wheel", 0..5, "*"
    score do |items|
      score_cardio(items[:high_number].to_s + '-' + items[:low_number].to_s)
    end
    check "Check Cardio values - incorrect value(s)" do |items|
      validate_cardio(items[:high_number].to_s + '-' + items[:low_number].to_s)
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