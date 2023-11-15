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
    return 2023
  end

  def mission_name
    return "FIRST MasterPiece"
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

  mission "M01 3D CINEMA" do
    item :three_d_cinema, "The 3D cinema's small red beam is completely to the right of the black frame?", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      (items[:three_d_cinema].to_i) * 20
    end
  end

  mission "M02 THEATER SCENE CHANGE" do
    item :theater_flag_color, "If your theater's red flag is down and the active scene color is:", "10, 20, 30", ["Blue", "Pink", "Orange", "No"], ["10", "20", "30" ,"0"]
    item :active_scenes_match, "Do both teams' active scenes match:", "20,30, 10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = (items[:theater_flag_color].to_i)
      bonus = 0
      if (items[:active_scenes_match] == "1")
        case (items[:theater_flag_color])
          when "10"
            bonus = 20
          when "20"
            bonus = 30
          when "30"
            bonus = 10
          when "No"
            bonus = 0
        end
      end

      s + bonus
    end
  end

  mission "M03 IMMERSIVE EXPERIENCE" do
    item :screens_raised, "The three immersive experience screens are raised?", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:screens_raised].to_i) * 20)
    end
  end

  mission "M04 MASTERPIECE" do
    item :art_piece_in_area, "Your team's LEGO art piece is at least partly in the museum target area?", "10", ["Yes", "No"], ["1", "0"]
    item :art_piece_bonus, "Bonus: And if the art piece is completely supported by the pedestal?", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
    	s = ((items[:art_piece_in_area].to_i) * 10)
    	s += ((items[:art_piece_bonus].to_i) * 20) if s > 0
      s
    end
  end

  mission "M05 AUGMENTED REALITY STATUE" do
    item :augmented_reality, "The augmented reality statue's orange lever is rotated completely to the right?", "30", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:augmented_reality].to_i) * 30)
    end
  end

  mission "M06 MUSIC CONCERT LIGHTS AND SOUNDS" do
    item :lights_rotated, "The lights' orange lever is rotated completely downwards?", "10", ["Yes", "No"], ["1", "0"]
    item :speakers_lever_rotated, "The speakers' orange lever is rotated completely to the left?", "10", ["Yes", "No"], ["1", "0"]
	  score do |items|
		  ((items[:lights_rotated].to_i) * 10) + ((items[:speakers_lever_rotated].to_i) * 10)
	  end

  end

  mission "M07 HOLOGRAM PERFORMER" do
    item :hologram_performer, "The hologram performer's orange push activator is completely past the black stage set line?",  "20", to_sa((0..3)), to_sa((0..3))
    score do |items|
      ((items[:hologram_performer].to_i) * 20)
    end
  end

  mission "M08 ROLLING CAMERA" do
    item :rolling_camera_position, "The rolling camera's white pointer is Left of:", "10", ["None", "Dark Blue", "Dark & Medium Blue", "Dark Medium & Light Blue"], ["0", "10", "20", "30"]

    score do |items|
       items[:rolling_camera].to_i
    end

  end

  mission "M09 MOVIE SET" do
    item :boat_touching_mat, "The boat is touching the mat and is completely past the black scene line?", "10", ["Yes", "No"], ["1", "0"]
    item :camera_in_target_area, "the camera is touching the mat and is at least partly in the camera target area?", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      (items[:boat_touching_mat].to_i * 10) + (items[:camera_in_target_area].to_i * 10)
    end
  end

  mission "M10 SOUND MIXER" do
    item :mixer_sliders_raised, "Sound mixer sliders raised?", "10", to_sa((0..3)), to_sa((0..3))
    score do |items|
     s = ((items[:mixer_sliders_raised].to_i) * 10)
    end

  end

  mission "M11 LIGHT SHOW" do
    item :light_show, "The light show's white pointer is within zone", "10", ["None", "Yellow", "Red", "Green"], ["0", "10", "20", "30"]
    score do |items|
      items[:light_show].to_i
    end
  end

  mission "M12 VIRTUAL REALITY ARTIST" do
    item :virtual_reality_chicken, "The chicken is intact and has moved from its starting position?", "10", ["Yes", "No"], ["1", "0"]
    item :chicken_bonus, "BONUS: the chicken is over or completely past the lavender dot", "20", to_sa((0..2)), to_sa((0..2))
    score do |items|
      s = ((items[:water_units_in_reservoir].to_i) * 10)
      s += ((items[:water_units_on_hook].to_i) * 20) if s > 0
      s
    end

  end

  mission "M13 CRAFT CREATOR" do
    item :craft_machine_lid_open, "The craft machine's orange and white lid is completely open?", "10", ["Yes", "No"], ["1", "0"]
    item :craft_machine_latch_down, "The craft machine's light pink latch is pointing straight down?", "20", ["Yes", "No"], ["1", "0"]
    score do |items|
      ((items[:craft_machine_lid_open].to_i) * 10) + ((items[:craft_machine_latch_down].to_i) * 20)
    end
  end

  mission "M14 AUDIENCE DELIVERY" do
    item :audience_members, "Audience members completely in a target destination:", "5", to_sa((0..7)), to_sa((0..7))
    item :target_destination, "A target destination has at least one audience member completely in", "5", to_sa((0..7)), to_sa((0..7))
    score do |items|
      s = ((items[:audience_members].to_i) * 5) + ((items[:target_destination].to_i) * 5)
    end
  end

  mission "M15 EXPERT DELIVERY" do
    item :sam, "Sam the Stage Manager in Movie Set", "10", ["Yes", "No"], ["1", "0"]
    item :anna, "Anna the Curator in Museum", "10", ["Yes", "No"], ["1", "0"]
    item :noah, "Noah the Sound Engineer in Music Concert", "10", ["Yes", "No"], ["1", "0"]
    item :izzy, "Izzy the Skateboarder in Skate Park", "10", ["Yes", "No"], ["1", "0"]
    item :emily, "Emily the Visual Effects Director in Cinema", "10", ["Yes", "No"], ["1", "0"]
    score do |items|
      s = ((items[:sam].to_i) * 10)
      s += ((items[:anna].to_i) * 10)
      s += ((items[:noah].to_i) * 10)
      s += ((items[:izzy].to_i) * 10)
      s += ((items[:emily].to_i) * 10)
    end
  end

  mission "M16 Precision" do
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
