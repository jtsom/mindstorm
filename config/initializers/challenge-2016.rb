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

YN = [1, 0]

################### The challenge definition -- READ THIS FIRST. It's the most important part of the project

challenge do

  mission "M04 Sorting - Yellow/Blue Bars in Matching Green Bin" do
    # Yellow/Blue Bars in Matching Green Bin

     item :bars_in_w_transfer, "Bars in Bins completely on/in West Transfer", "7", ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
     item :bars_not_in_w_transfer, "Bars in Bins NEVER completely in W. Transfer", "6", ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15"], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
    score do |items|
      ((items[:bars_in_w_transfer] || 0) * 7) + ((items[:bars_not_in_w_transfer] || 0) * 6)
    end
    check "Too many blue/yellow bars!" do |items|
      ((items[:bars_in_w_transfer] || 0) + (items[:bars_not_in_w_transfer] || 0)) <= 15
    end
  end

  mission "M04 Sorting - Black Bars Only" do
    item :bars_in_original_position, "Bars in original position / scoring Flower Box", "20", ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    item :bars_in_green_bin_or_landfill, "Bars in matching Green Bin or Landfill", "20", ["0", "1", "2", "3", "4", "5", "6", "7", "8"], [0, 1, 2, 3, 4, 5, 6, 7, 8]
    item :bars_elsewhere, "Bars elsewhere in play", "20", ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    score do |items|
      ((items[:bars_in_original_position] || 0) * 8) + ((items[:bars_in_green_bin_or_landfill] || 0) * 3) + ((items[:bars_elsewhere] || 0) * -8)
    end
    check "Too many Black bars!" do |items|
      ((items[:bars_in_original_position] || 0) + (items[:bars_in_green_bin_or_landfill] || 0) + (items[:bars_elsewhere] || 0)) <= 12
    end
  end

  mission "M02 Methane" do
    item :in_truck_or_factory, "Methane in truck or factory", "40", ["0", "1", "2"], [0, 1, 2]
    score do |items|
      ((items[:in_truck_or_factory] || 0) * 40)
    end
  end

  mission "M03 Transport" do
    item :truck_supporting_yellow_bin, "Truck supporting yellow bin", "50", ["No", "Yes"], [0, 1]
    item :yellow_bin_east_of_truck_guide, "Yellow bin east of truck guide", "60", ["No", "Yes"], [0, 1]
    score do |items|
      ((items[:truck_supporting_yellow_bin] || 0) * 50) + ((items[:yellow_bin_east_of_truck_guide] || 0) * 60)
    end
  end

  mission "M05 Careers" do
    item :one_peron_in_sorter_ares, "At least one person in sorter area?", "60", ["No", "Yes"], [0, 1]
    score do |items|
      ((items[:one_peron_in_sorter_ares] || 0) * 60)
    end
  end

  #check
  mission "M06 Scrap Cars" do
      item :engine_installed, "Engine correctly installed",  "65", ["No", "Yes"], [0, 1]
      item :car_folded_east_area, "Car folded and in East Transit Area?", "50", ["No", "Yes"], [0, 1]
      item :car_never_in_safety, "Car NEVER even partly in Safety", "0", ["No", "Yes"], [0, 1]
      score do |items|
        ((items[:engine_installed] || 0) * 65) + ((items[:car_folded_east_area] || 0) * 50) * (items[:car_never_in_safety] || 0)
      end
      check "Engine installed OR Car folded, not both" do |items|
        (items[:engine_installed] + items[:car_folded_east_area]) <= 1
      end
    end

  mission "M08 Composting" do
    item :compost_ejected, "Compost ejected and not in Safety?", "60", ["No", "Yes"], [0, 1]
    item :compost_in_safety, "Compost ejected and In Safety?", "80", ["No", "Yes"], [0, 1]
    score do |items|
       ((items[:compost_ejected] || 0) * 60) + ((items[:compost_in_safety] || 0) * 80)
    end
    check "Compost can be in or out of Safety" do |items|
      (items[:compost_ejected] + items[:compost_in_safety]) <= 1
    end
  end

  mission "M07 Cleanup" do
      item :plastic_bad_in_safety, "Plastic bags in Safety?", "30", ["0", "1", "2"], [0, 1, 2]
      item :animals_in_circle, "Animals in circles without plastic bags?", "20", ["0", "1", "2", "3"], [0, 1, 2, 3]
      item :chicken_bonus, "Chicken in small circle?", "35", ["No", "Yes"], [0, 1]
      score do |items|
        ((items[:plastic_bad_in_safety] || 0) * 30) + ((items[:animals_in_circle] || 0) * 20) + ((items[:chicken_bonus] || 0) * 35)
      end
    end

  mission "M10 Demolition" do
      item :no_beams_standing, "All beams no longer in setup position?", "85", ["No", "Yes"], [0, 1]
      score do |items|
         ((items[:no_beams_standing] || 0) * 85)
      end
    end

    mission "M01 Using Recycled Material" do
      item :your_bin_in_opp_safety, "Your Green Bins w/ Matching Yel/Blu bar in Opp Safety?", "60", ["0", "1", "2"], [0, 1, 2]
      item :opp_bin_in_your_safety, "Opp Green Bins w/ Matching Yel/Blu bar in Your Safety?", "60", ["0", "1", "2"], [0, 1, 2]

      score do |items|
        ((items[:your_bin_in_opp_safety] || 0) * 60) + ((items[:opp_bin_in_your_safety] || 0) * 60)
      end
    end

  mission "M09 Salvage" do
      item :valueable_in_safety, "Valuables in Safety?", "60", ["No", "Yes"], [0, 1]
      score do |items|
         ((items[:valueable_in_safety] || 0) * 60)
      end
    end

  mission "M11 Purchasing Decisions" do
    item :planes_in_safety, "Planes completely in Safety?", "40", ["0", "1", "2"], [0, 1, 2]
    score do |items|
       ((items[:planes_in_safety] || 0) * 40)
    end
  end

  #check
  mission "M12 Repurposing" do
    item :compost_in_package, "Compost perfectly nested in empty Toy Package?", "40", ["No", "Yes"], [0, 1]
    item :package_in_original_condition, "Package in original condition?", "40", ["No", "Yes"], [0, 1]

    score do |items|
       ((items[:compost_in_package] || 0) * (items[:package_in_original_condition] || 0)) * 40
    end
  end


end
