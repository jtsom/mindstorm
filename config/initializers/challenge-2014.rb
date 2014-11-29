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
    2014
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
    
    #hack but....
    marker_color_values = @missions[12].items[1]
    
    mcv = marker_color_values.values[result[:marker_color]]
    marker_ticks_values = @missions[12].items[2]
    mtv = marker_ticks_values.values[result[:marker_ticks]]
    
    bar_south = result[:bar_south]

    bonus = (mcv + mtv) * bar_south
        
    raw_score += ((raw_score * bonus) / 100.0).ceil
    
    raw_score += (bar_south * 20)

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

def rev_engineering_score(items)
  score = ((items[:basket_in_base] || 0 )* 15)
  score += (items[:basket_in_base] || 0) * ((items[:model_identical] || 0 )* 30)
end

################### The challenge definition -- READ THIS FIRST. It's the most important part of the project

challenge do
  mission "Reverse Engineering" do
    item :basket_in_base, "Basket in base?", "30", ["No", "Yes"], [0, 1]
    item :model_identical, "Your model is in Base, and is \"identical\"", "45", ["No", "Yes"], [0, 1]

    score do |items|
      rev_engineering_score(items)
    end
    
  end

  mission "Opening Doors" do
    item :door_open, "Door opened by pushing handle down", "15", ["No", "Yes"], [0, 1]
    score do |items|
      (items[:door_open] || 0) * 15
    end
  end

  mission "Project-Based Learning" do
      item :loops_on_scale, "Loops on scale", "10", ["0", "1", "2", "3", "4", "5", "6", "7", "8"], ["0", "1", "2", "3", "4", "5", "6", "7", "8"]
      score do |items|
        (items[:loops_on_scale] || 0) != 0 ? (items[:loops_on_scale] || 0) * 10 + 10 : 0
      end
      check "Cannot use more than 8 loops!" do |items|
        ((1 - (items[:loop_touch] || 0)) + 
         (1 - (items[:senses_touch] || 0)) + 
         ((items[:engine_loop] || 0) * 2) +
         (1 - (items[:community_touch] || 0)) +
         (items[:project] || 0)) <= 8
      end
    end

  mission "Apprenticeship" do
    item :model_presented, "Model presented to Referee?", "20", ["No", "Yes"], [0, 1]
    item :model_touching_circle, "Touching circle, not in Base, people bound?", "35", ["No", "Yes"], [0, 1]
    score do |items|
      ((items[:model_presented] || 0) * 20) + ((items[:model_presented] || 0) * ((items[:model_touching_circle] || 0) * 15))
    end
  end

  mission "Search Engine" do
    item :slider_wheel_spin, "Only Slider caused wheel to spin 1+ times?", "15", ["No", "Yes"], [0, 1]
    item :correct_loop_removed, "Only correct loop removed?", "45", ["No", "Yes"], [0, 1]
    score do |items|
      ((items[:slider_wheel_spin] || 0) * 15) + (((items[:slider_wheel_spin] || 0 ) * (items[:correct_loop_removed] || 0)) * 45)
    end
  end

  mission "Sports" do
      item :ball_shot, "Ball shot from East/North of \"Shot Lines\" to Net",  "30", ["No", "Yes"], [0, 1]
      item :ball_in_net, "Ball touching mat in Net at end of match", "30", ["No", "Yes"], [0, 1]
      score do |items|
        ((items[:ball_shot] || 0) * 30) + (((items[:ball_shot] || 0) * (items[:ball_in_net] || 0)) * 30)
      end
    end

  mission "Robotics Competition" do
      item :robotics_installed, "Only Robotics Insert installed?", "25", ["No", "Yes"], [0, 1]
      item :robotics_loop_touch, "Loop no longer touching model?", "30", ["No", "Yes"], [0, 1]
      score do |items|
        (items[:robotics_installed] || 0) * 25 + (((items[:robotics_installed] || 0) * (items[:robotics_loop_touch] || 0)) * 30)
      end
    end

  mission "Using the Right Senses" do
      item :senses_touch, "Loop no longer touching model?", "40", ["No", "Yes"], [0, 1]
      score do |items|
         ((items[:senses_touch] || 0) * 40)
      end
    end

  mission "Remote Communication/Learning" do
      item :robot_pull, "Referee saw robot pull slider west?", "40", ["No", "Yes"], [0, 1]
      score do |items|
         ((items[:robot_pull] || 0) * 40)
      end
    end

  mission "Thinking Outside the Box" do
      item :idea_touch, "Idea model not touching Box, Box never in Base?", "25", ["No", "Yes"], [0, 1]
      item :bulb_up, "Bulb faces UP?", "40", ["No", "Yes"], [0, 1]
      score do |items|
         ((items[:idea_touch] || 0) * 25) + (((items[:idea_touch] || 0) * (items[:bulb_up] || 0)) * 15)
      end
    end

  mission "Community Learning" do
    item :community_touch, "Loop no longer touching model?", "25", ["No", "Yes"], [0, 1]
    score do |items|
       ((items[:community_touch] || 0) * 25)
    end
  end

  mission "Cloud Access" do
    item :key_up, "SD card is UP due to inserted \"key\"?",  "30", ["No", "Yes"], [0, 1]
    score do |items|
       ((items[:key_up] || 0) * 30)
    end
  end

  mission "Engagement" do
    item :bar_south, "Yellow section moved south?", "20", ["No", "Yes"], [0, 1]
    item :marker_color, "Dial major marker Color", "20", ["N/A", "Red 10%", "Orange 16%", "Green 22%", "Blue 28%", "Red 34%", "Blue 40%", "Green 46%", "Orange 52%", "Red 58%"], [0, 10, 16, 22, 28, 34, 40, 46, 52, 58]
    item :marker_ticks, "Ticks past major marker", "20", ["N/A", "0", "1", "2", "3", "4", "5"], [0, 0, 1, 2, 3, 4, 5]
    score do |items|
		0
    end
  end

  mission "Adapting to Changing Conditions" do
    item :model_rotated, "Model rotated 90-ish degrees CCW?", "15", ["No", "Yes"], [0, 1]
    score do |items|
       ((items[:model_rotated] || 0) * 15)
    end
  end

  mission "Penalties" do
    item :penalties, "Robot, Sprawl, Junk Penalties", "15", ["0", "1", "2", "3", "4", "5", "6", "7", "0"], [0, 10, 20, 30, 40, 50 ,60, 70, 80]
    score do |items|
       ((items[:penalties] || 0) * -10)
    end
  end
              
  

end
