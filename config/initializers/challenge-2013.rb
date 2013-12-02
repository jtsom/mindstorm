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
    
    if raw_score < 0
      raw_score = 0
    end
    
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
  mission "Tree Branch" do
    item :tree_branch_down, "Tree branch closer to mat than cable?", YN, "30"
    item :cables_upright, "Tree/electrical cable models upright?", YN, "30"
    
    score do |items|
      (items[:tree_branch_down] * items[:cables_upright]) * 30
    end
  end

  mission "House Lift" do
    item :house_lifted, "House locked in high position?", YN, "25"
    score do |items|
      items[:house_lifted] * 25
    end
  end

  mission "Progress" do
    item :pointer_progress, "Colors Reached", 0..16, "2"
    score do |items|
      items[:pointer_progress] * 2
    end
  end

  mission "Base Isolation Test" do
    item :west_tan_buildings_undamaged, "West tan building undamaged?", YN, "30"
    item :east_tan_buildings_damaged, "East tan building damaged?", YN, "30"
    score do |items|
      (items[:west_tan_buildings_undamaged] * items[:east_tan_buildings_damaged] ) * 30
    end
  end
  
  mission "Construction Relocation" do
    item :building_segments_in_lt_green, "Any gray building segments in Lt Green?", YN, "20"
    score do |items|
      (1 - items[:building_segments_in_lt_green]) * 20
    end
  end
    
  mission "Supply Truck" do
      item :truck_touching_yellow, "Supply truck touching yellow region", YN, "20"
      score do |items|
        (items[:truck_touching_yellow] * 20)
      end
    end

  mission "Ambulance" do
      item :ambulance_in_yellow, "Ambulance in yellow region?", YN, "25"
      score do |items|
        items[:ambulance_in_yellow] * 25
      end
    end

  mission "Cargo Plane" do
      item :cargo_plane_in_yellow_only, "Cargo plane in yellow region Only?", YN, "20"
      item :cargo_plane_in_ltblue, "Cargo plane in Lt. Blue region?", YN, "30"
      score do |items|
         (items[:cargo_plane_in_yellow_only] * 20) + (items[:cargo_plane_in_ltblue] * 30)
      end
      check "Plane is in Yellow Only or Lt Blue" do |items|
        (items[:cargo_plane_in_yellow_only] + items[:cargo_plane_in_ltblue]) <= 1
      end
    end

  mission "Game Penalty" do
    item :penalties, "Penalties Assessed", 0..8, "-13/-10"  
    item :small_junk_penalties, "Small Junk Penalties (Debris pieces outside blue)", 0..4, "-10"
    item :large_junk_penalties, "Large Junk Penalties (Debris pieces in blue)", 0..4, "-13"   
    score do |items|
      (items[:large_junk_penalties] * -13) + (items[:small_junk_penalties] * -10)
    end

    check "Max of 8 items!" do |items|
      (items[:large_junk_penalties] + items[:small_junk_penalties]) <= 8
    end
  end

  mission "Runway" do
      item :runway_clear, "Runway clear (except water and plane)?", YN, "30"
      score do |items|
        items[:runway_clear] * 30
      end
    end
                  
  mission "Evacuation Sign" do
    item :evacuation_sign_up, "Evacuation sign up?", YN, "30"
    score do |items|
      items[:evacuation_sign_up] * 30
    end
  end

  mission "Code Construction" do
    item :building_segments_in_pink, "Highest Multi Story Building Segments?", 0..5, "5"
    score do |items|
      items[:building_segments_in_pink] * 5
    end
  end
  
  mission "Family" do
    item :largest_group, "Two or three family together?", 0..3, "33/66"
    item :people_with_water, "People have water", 0..3, "15"
    item :people_in_yellow, "People in yellow region", 0..3, "12"
    item :people_in_red, "People in red region", 0..3, "18"
    item :pets_with_people, "Pets with People", 0..2, "15"
    score do |items|
      (items[:largest_group] <= 1 ? 0 : items[:largest_group] == 2 ? 33 : 66) + (items[:people_with_water] * 15) + (items[:people_in_yellow] * 12) + (items[:people_in_red] * 18) + (items[:pets_with_people] * 15)
    end
    check "There are only 3 people - check Family category!" do |items|
      (items[:people_in_red] + items[:people_in_yellow]) < 4
    end
  end

  mission "Supplies & Equipment" do
    item :supplies_in_yellow, "Non Water Supplies in yellow with People", 0..12, "3"
    item :supplies_in_red, "Non WaterSupplies in red with People", 0..12, "4"
    score do |items|
      (items[:supplies_in_yellow] * 3) + (items[:supplies_in_red] * 4)
    end

    check "Max of 12 items!" do |items|
      (items[:supplies_in_yellow] + items[:supplies_in_red]) <= 12
    end
  end

  mission "Safe Place" do
    item :robot_in_red, "Robot in red region", YN, "25"
    score do |items|
      (items[:robot_in_red] * 25)
    end
  end

  mission "Obstacles" do
    item :crossed_dkblue, "Robot crossed dark blue?", YN, "10"
    item :crossed_dkgreen, "Robot crossed dark green?", YN, "16"
    item :crossed_purple, "Robot crossed purple?", YN, "23"
    item :crossed_red, "Robot crossed red?", YN, "31"
    
    score do |items|
      (items[:crossed_dkblue] * 10) + (items[:crossed_dkgreen] * 16) + (items[:crossed_purple] * 23) + (items[:crossed_red] * 31)
    end
    check "Robot scores furthest crossing furthest segment only" do |items|
      (items[:crossed_dkblue] + items[:crossed_dkgreen] + items[:crossed_purple] + items[:crossed_red]) <= 1
    end
  end
  
  mission "Tsunami" do
    item :tsunami, "Three tsunami waves touching mat?", YN, "20"
    score do |items|
      items[:tsunami] * 20
    end
  end
  
end
