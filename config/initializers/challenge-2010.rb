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

challenge do
  mission "Common Bone Repair" do
    item :cast_applied, "Cast Applied?", YN, "25"
    score do |items|
      items[:cast_applied] * 25
    end
  end
  
  mission "Special Bone Repair" do
    item :bone_bridge_inserted, "Bone Bridge Inserted?", YN, "15"
    item :goal_scored, "Goal Scored?", YN, "25"
    score do |items|
      (items[:bone_bridge_inserted] * 15) + (items[:goal_scored] * 25)
    end
  end
  
  mission "Rapid Blood Screening" do
    item :syringe_in_base, "Syringe In Base?", YN, "25"
    item :white_cells_patient_area, "All White Cells in Patient Area?", YN, "15"
    score do |items|
      (items[:syringe_in_base] * 25) +  (items[:white_cells_patient_area] * 15)
    end
  end

  mission "Bad Cell Destruction" do
    item :bad_cell_identification, "Bad Cells Identified?", YN, "20"
    item :bad_cell_destruction, "Bad Cells Destroyed?", YN, "25"
    score do |items|
      (items[:bad_cell_identification] * 20) + (items[:bad_cell_destruction] * 25)
    end
    check "Bad cells must be Indentified OR Destroyed, not both" do |items|
      (items[:bad_cell_identification] + items[:bad_cell_destruction]) <= 1
    end
  end
  
  mission "Mechanical Arm Patent" do
    item :patient_grabbed, "Patient Grabbed by Your Side?", YN, "25"
    score do |items|
      items[:patient_grabbed] * 25
    end
  end
  
  mission "Cardiac Patch" do
    item :patch_applied, "Cardiac Patch Applied?", YN, "20"
    score do |items|
      items[:patch_applied] * 20
    end
  end
  
  mission "Pace Maker" do
    item :pace_maker_inserted, "Pace Maker Inserted?", YN, "25"
    score do |items|
      items[:pace_maker_inserted] * 25
    end
  end
  
  mission "Nerve Mapping" do
    item :nerve_mapped, "Nerve Input/Output Mapped?", YN, "15"
    score do |items|
      items[:nerve_mapped] * 15
    end
  end 
  
  mission "Object Control Through Thought" do
    item :door_open, "Door Open At Least Halfway?", YN, "20"
    score do |items|
      items[:door_open] * 20
    end
  end  
  
  mission "Medicine Auto-Dispensing" do
    item :bluewhite_off, "Blue and White off, Pinks on?", YN, "25"
    item :container_in_patient_area, "ABlue and White in container in patient area?", YN, "5"
    score do |items|
      (items[:bluewhite_off] * 25) +  (items[:container_in_patient_area] * 5)
    end
  end
   
  mission "Robotic Sensitivity" do
    item :weight_raised, "Weight is all the way up?", YN, "25"
    score do |items|
      items[:weight_raised] * 25
    end
  end
  
  mission "Professional Teamwork" do
    item :people_together, "People Together in Patient's Area?", YN, "25"
    score do |items|
      items[:people_together] * 25
    end
  end
 
  mission "Bionic Eyes" do
    item :bionic_eye_touching, "At least one Eye Touching Upper Body?", YN, "20"
    score do |items|
      items[:bionic_eye_touching] * 20
    end
  end

   mission "Stent" do
     item :stent_installed, "Stent Installed/Artery Expanded?", YN, "25"
     score do |items|
       items[:stent_installed] * 25
     end
   end   
 
   mission "Red Blood Cells (touch penalty)" do
     item :AccessMarkers, "Red Blood Cells on Table", 0..8, "5"
     score do |items|
       (items[:AccessMarkers] * 5)
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