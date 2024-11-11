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
    return 2024
  end

  def mission_name
    return "FIRST Submerged"
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
    @checks.inject(true) { |valid, pair|
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
    item :robot_inspection, "Robot and all of its equipment fit completely in one launch area?", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      (items[:robot_inspection].to_i) * 20
    end
  end

  mission "M01 CORAL NURSERY" do
    item :coral_tree_hanging, "The coral tree is hanging on the coral tree support", "20", ["Yes", "No"], ["1", "0"]
    item :coral_tree_in_holder, "The bottom of the coral tree is in its holder", "10", ["Yes", "No"], ["1", "0"]
    item :coral_buds_flipped_up, "The coral buds are flipped up", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = (items[:coral_tree_hanging].to_i) * 20
      s += ((items[:coral_tree_in_holder].to_i) * 10) if s > 0
      s += (items[:coral_buds_flipped_up].to_i) * 20
      s
    end
  end

  mission "M02 SHARK" do
    item :shark_not_touching_cave, "The shark is no longer touching the cave:", "20", ["Yes", "No"], ["1", "0"]
    item :shark_touching_mat_in_habitat, "The shark is touching the mat and is at least partly in the shark habitat:", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = (items[:shark_not_touching_cave].to_i) * 20
      s += ((items[:shark_touching_mat_in_habitat].to_i) * 10) if s > 0
      s
    end
  end

  mission "M03 CORAL REEF" do
    item :coral_reef_flipped_up, "The coral reef is flipped up, not touching the mat:", "20", ["Yes", "No"], ["1", "0"]
    item :reef_segments_upright, "If a reef segment is standing upright, outside of home, and touching the mat:", "5", to_sa((0..3)), to_sa((0..3))
    score do |items|
      s = ((items[:coral_reef_flipped_up].to_i) * 20)
      s += ((items[:reef_segments_upright].to_i) * 5)
      s
    end
  end

  mission "M04 SCUBA DIVER" do
    item :scuba_diver_not_touching_nursery, "The scuba diver is no longer touching the coral nursery:", "20", ["Yes", "No"], ["1", "0"]
    item :scuba_diver_hanging, "The scuba diver is hanging on the coral reef support:", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
    	s = ((items[:scuba_diver_not_touching_nursery].to_i) * 20)
    	s += ((items[:scuba_diver_hanging].to_i) * 20) if s > 0
      s
    end
  end

  mission "M05 ANGLER FISH" do
    item :angler_fish, "The angler fish is latched within the shipwreck:", "30", ["Yes", "No"], ["1", "0"]
    score do |items|
      (items[:angler_fish].to_i) * 30
    end
  end

  mission "M06 RAISE THE MAST" do
    item :ships_mast_raised, "The shipwreck's mast is completely raised:", "30", ["Yes", "No"], ["1", "0"]
	  score do |items|
		  (items[:ships_mast_raised].to_i) * 30
	  end

  end

  mission "M07 KRAKEN'S TREASURE" do
    item :chest_outside_nest, "The treasure chest is completely outside the kraken's nest:",  "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:chest_outside_nest].to_i) * 20)
    end
  end

  mission "M08 ARTIFICIAL HABITAT" do
    item :habitat_segments_flat, "Number of artificial habitat stack segments completely flat and upright:", "10", to_sa((0..4)), to_sa((0..4))

    score do |items|
       (items[:habitat_segments_flat].to_i) * 10
    end

  end

  mission "M09 UNEXPECTED ENCOUNTER" do
    item :unknown_creature_released, "The unknown creature is released:", "20", ["Yes", "No"], ["1", "0"]
    item :creature_in_cold_seep, "The unknown creature is at least partly in the cold seep:", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = (items[:unknown_creature_released].to_i * 20)
      s += (items[:creature_in_cold_seep].to_i * 10) if s > 0
      s
    end
  end

  mission "M10 SEND OVER THE SUBMERSIBLE" do
    item :yellow_flag_down, "Your team's yellow flag is down:", "30", ["Yes", "No"], ["1", "0"]
    item :submersible_closer_to_opposing_field, "The submersible is clearly closer to the opposing field:", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
     s = ((items[:yellow_flag_down].to_i) * 30)
     s += ((items[:submersible_closer_to_opposing_field].to_i) * 10) if s > 0
     s
    end

  end

  mission "M11 SONAR DISCOVERY" do
    item :whales, "Number of whales revealed:", "20", ["0", "1", "2"], ["0", "20", "30"]
    score do |items|
      items[:whales].to_i
    end
  end

  mission "M12 FEED THE WHALE" do
    item :krill_amount, "Number of krill at least partly in the whale's mouth:", "10", to_sa((0..5)), to_sa((0..5))
    score do |items|
      ((items[:krill_amount].to_i) * 10)
    end

  end

  mission "M13 CHANGING SHIPPING LANES" do
    item :ship_in_new_shipping_lane, "The ship is in the new shipping lane, touching the mat:", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:ship_in_new_shipping_lane].to_i) * 20)
    end
  end

  mission "M14 SAMPLE COLLECTION" do
    item :sample_outside_area, "The water sample is completely outside the water sample area:", "5", ["Yes", "No"], ["1", "0"]
    item :seabed_sample_not_touching, "The seabed sample is no longer touching the seabed:", "10", ["Yes", "No"], ["1", "0"]
    item :plankton_not_touching_forest, "The plankton sample is no longer touching the kelp forest:", "10", ["Yes", "No"], ["1", "0"]
    item :trident_pieces_not_touching_shipwreck, "Number of trident pieces no longer touching the shipwreck:", "5", ["0", "1", "2"], ["0", "20", "30"]

    score do |items|
      s = ((items[:sample_outside_area].to_i) * 5)
      s += ((items[:seabed_sample_not_touching].to_i) * 10)
      s += ((items[:plankton_not_touching_forest].to_i) * 10)
      s += (items[:trident_pieces_not_touching_shipwreck].to_i)
      s
    end
  end

  mission "M15 RESEARCH VESSEL" do
    item :items_in_cargo_area, "Number of samples, trident part(s), or treasure chest at least partly in the research vessel's cargo area:", "5", to_sa((0..6)), to_sa((0..6))
    item :ports_latch_in_vessel_loop, "The ports latch is at least partly in the research vessel's loop:", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = items[:items_in_cargo_area].to_i * 5
      s += items[:ports_latch_in_vessel_loop].to_i * 20
      s
    end
  end

  mission "PT PRECISION TOKENS" do
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
