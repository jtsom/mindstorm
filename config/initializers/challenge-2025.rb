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
    return 202
  end

  def mission_name
    return "FIRST Unearthed"
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

  mission "M01 Surface Brushing (E)" do
    item :soil_deposits_cleared, "Soil deposits are completely cleared, touching the mat:", "10", to_sa((0..2)), to_sa((0..2))
    item :brush_not_touching, "Archaeologist's brush is not touching the dig site:", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = (items[:soil_deposits_cleared].to_i) * 10
      s += ((items[:brush_not_touching].to_i) * 10)
      s
    end
  end

  mission "M02 Map Reveal" do
    item :topsoil_sections_cleared, "Topsoil sections completely cleared:", "10", to_sa((0..3)), to_sa((0..3))
    score do |items|
      s = (items[:topsoil_sections_cleared].to_i) * 10
      s
    end
  end

  mission "M03 Mineshaft Explorer" do
    item :minecart_on_opposing_field, "Your team's minecart is on the opposing team's field: ", "30", ["Yes", "No"], ["1", "0"]
    item :opposing_mindcart_on_field, "Bonus: And the opposing team's minecart is on your team's field: ", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:minecart_on_opposing_field].to_i) * 30)
      s += ((items[:opposing_mindcart_on_field].to_i) * 10) if s > 0
      s
    end
  end

  mission "M04 Careful Recovery (E)" do
    item :artifact_not_touching_mine, "Precious artifact is not touching the mine:", "30", ["Yes", "No"], ["1", "0"]
    item :support_structures_standing, "Both support structures are standing:", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
    	s = ((items[:artifact_not_touching_mine].to_i) * 30)
    	s += ((items[:support_structures_standing].to_i) * 10)
      s
    end
  end

  mission "M05 Who Lived Here? (E)" do
    item :floor_upright, "Structure floor is completely upright:", "30", ["Yes", "No"], ["1", "0"]
    score do |items|
      (items[:floor_upright].to_i) * 30
    end
  end

  mission "M06 Forge" do
    item :ore_blocks, "Ore blocks not touching the forge:", "10", to_sa((0..3)), to_sa((0..3))
	  score do |items|
		  (items[:ore_blocks].to_i) * 10
	  end

  end

  mission "M07 Heavy Lifting" do
    item :millstone_not_touching_base, "Millstone is no longer touching its base:",  "30", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:millstone_not_touching_base].to_i) * 30)
    end
  end

  mission "M08 Silo" do
    item :pieces_outside_silo, "Preserved pieces outside the silo:", "10", to_sa((0..3)), to_sa((0..3))

    score do |items|
       (items[:pieces_outside_silo].to_i) * 10
    end

  end

  mission "M09 What's on Sale? (E)" do
    item :roof_raised, "Roof is completely raised:", "20", ["Yes", "No"], ["1", "0"]
    item :wares_raised, "Market wares are raised:", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = (items[:roof_raised].to_i * 20)
      s += (items[:wares_raised].to_i * 10)
      s
    end
  end

  mission "M10 Tip the Scales" do
    item :scale_tipped, "Scale is tipped and touching the mat:", "20", ["Yes", "No"], ["1", "0"]
    item :scale_pan_removed, "Scale pan is completely removed:", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
     s = ((items[:scale_tipped].to_i) * 20)
     s += ((items[:scale_pan_removed].to_i) * 10)
     s
    end

  end

  mission "M11 Angler Artifacts (E)" do
    item :artifacts_raised, "Artifacts are raised above the ground layer:", "20", ["Yes", "No"], ["1", "0"]
    item :crane_lowered, "Bonus: And the crane flag is at least partly lowered:", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = (items[:artifacts_raised].to_i) * 20
      s += (items[:crane_lowered].to_i) * 10 if s > 0
      s
    end
  end

  mission "M12 Salvage Operation (E)" do
    item :sand_cleared, "Sand is completely cleared:", "20", ["Yes", "No"], ["1", "0"]
    item :ship_raised, "Ship is completely raised: ", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:sand_cleared].to_i) * 20)
      s += (items[:ship_raised].to_i) * 10
      s
    end
  end

  mission "M13 Statue Rebuild (E)" do
    item :statue_raised, "Statue is completely raised:", "30", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:statue_raised].to_i) * 30)
    end
  end

  mission "M14 Forum (E)" do
    item :artifacts_in_forum, "Artifacts touching the mat and at least partly in the forum:", "5", to_sa((0..7)), to_sa((0..7))

    score do |items|
      s = ((items[:artifacts_in_forum].to_i) * 5)
    end
  end

  mission "M15 Site Marking" do
    item :flag_touching_mat, "Sites with a flag at least partly inside and touching the mat:", "10", to_sa((0..3)), to_sa((0..3))
    item :ports_latch_in_vessel_loop, "The ports latch is at least partly in the research vessel's loop:", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = items[:flag_touching_mat].to_i * 10
      s += (items[:ports_latch_in_vessel_loop].to_i * 20)
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
