# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101119003832) do

  create_table "corevalue_scores", :force => true do |t|
    t.integer  "i_discovery"
    t.integer  "i_team_spirit"
    t.integer  "i_integration"
    t.text     "i_comments"
    t.integer  "t_effectiveness"
    t.integer  "t_efficiency"
    t.integer  "t_initiative"
    t.text     "t_comments"
    t.integer  "g_inclusion"
    t.integer  "g_respect"
    t.integer  "g_coopertition"
    t.text     "g_comments"
    t.integer  "total_score"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "judge_name"
  end

  create_table "matches", :force => true do |t|
    t.integer  "match_number"
    t.integer  "score"
    t.text     "results"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "table_number"
    t.string   "type"
  end

  add_index "matches", ["type"], :name => "index_matches_on_type"

  create_table "project_scores", :force => true do |t|
    t.integer  "total_score"
    t.integer  "research1"
    t.integer  "research2"
    t.integer  "research3"
    t.integer  "research4"
    t.integer  "research5"
    t.integer  "is1"
    t.integer  "is2"
    t.integer  "is3"
    t.integer  "sharing1"
    t.integer  "sharing2"
    t.integer  "pres1"
    t.integer  "pres2"
    t.integer  "pres3"
    t.integer  "pres4"
    t.integer  "pres5"
    t.integer  "pres6"
    t.integer  "pres7"
    t.integer  "pres8"
    t.integer  "pres9"
    t.integer  "pres10"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id"
    t.integer  "research6"
    t.integer  "r_problemID"
    t.integer  "r_source"
    t.integer  "r_analysis"
    t.integer  "r_review"
    t.text     "r_comments"
    t.integer  "i_teamsolution"
    t.integer  "i_innovation"
    t.integer  "i_implementation"
    t.text     "i_comments"
    t.integer  "p_preseffective"
    t.integer  "p_creativity"
    t.integer  "p_sharing"
    t.text     "p_comments"
    t.string   "judge_name"
  end

  add_index "project_scores", ["team_id"], :name => "index_project_scores_on_team_id"

  create_table "robot_scores", :force => true do |t|
    t.integer  "inno_design"
    t.integer  "strategy1"
    t.integer  "strategy2"
    t.integer  "loconav1"
    t.integer  "loconav2"
    t.integer  "loconav3"
    t.integer  "loconav4"
    t.integer  "loconav5"
    t.integer  "prog1"
    t.integer  "prog2"
    t.integer  "prog3"
    t.integer  "prog4"
    t.integer  "prog5"
    t.integer  "prog6"
    t.integer  "prog7"
    t.integer  "prog8"
    t.integer  "kids1"
    t.integer  "kids2"
    t.integer  "kids3"
    t.integer  "structural1"
    t.integer  "structural2"
    t.integer  "structural3"
    t.integer  "structural4"
    t.integer  "structural5"
    t.integer  "overall1"
    t.integer  "overall2"
    t.integer  "overall3"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id"
    t.integer  "total_score"
    t.integer  "m_durability"
    t.integer  "m_efficiency"
    t.integer  "m_mechanization"
    t.text     "m_comments"
    t.integer  "p_quality"
    t.integer  "p_efficiency"
    t.integer  "p_automation"
    t.text     "p_comments"
    t.integer  "i_designprocess"
    t.integer  "i_strategy"
    t.integer  "i_innovation"
    t.text     "i_comments"
    t.string   "judge_name"
  end

  add_index "robot_scores", ["team_id"], :name => "index_robot_scores_on_team_id"

  create_table "teams", :force => true do |t|
    t.integer  "fll_number"
    t.string   "team_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "school"
    t.string   "town"
    t.string   "coach"
    t.string   "coach_email"
    t.string   "asst_coach"
    t.string   "asst_coach_email"
    t.string   "state"
  end

end
