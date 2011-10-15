# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20111013225707) do

  create_table "competitions", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "from_email"
    t.string   "full_name"
  end

  create_table "corevalue_scores", :force => true do |t|
    t.integer  "i_discovery",     :default => 0
    t.integer  "i_team_spirit",   :default => 0
    t.integer  "i_integration",   :default => 0
    t.text     "i_comments"
    t.integer  "t_effectiveness", :default => 0
    t.integer  "t_efficiency",    :default => 0
    t.integer  "t_initiative",    :default => 0
    t.text     "t_comments"
    t.integer  "g_inclusion",     :default => 0
    t.integer  "g_respect",       :default => 0
    t.integer  "g_coopertition",  :default => 0
    t.text     "g_comments"
    t.integer  "total_score"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "judge_name"
    t.integer  "inspiration"
    t.integer  "teamwork"
    t.integer  "grac_prof"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id"
    t.integer  "r_problemID",         :default => 0
    t.integer  "r_source",            :default => 0
    t.integer  "r_analysis",          :default => 0
    t.integer  "r_review",            :default => 0
    t.text     "r_comments"
    t.integer  "i_teamsolution",      :default => 0
    t.integer  "i_innovation",        :default => 0
    t.integer  "i_implementation",    :default => 0
    t.text     "i_comments"
    t.integer  "p_preseffective",     :default => 0
    t.integer  "p_creativity",        :default => 0
    t.integer  "p_sharing",           :default => 0
    t.text     "p_comments"
    t.string   "judge_name"
    t.integer  "research"
    t.integer  "innovative_solution"
    t.integer  "presentation"
  end

  add_index "project_scores", ["team_id"], :name => "index_project_scores_on_team_id"

  create_table "robot_scores", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id"
    t.integer  "total_score"
    t.integer  "m_durability",        :default => 0
    t.integer  "m_efficiency",        :default => 0
    t.integer  "m_mechanization",     :default => 0
    t.text     "m_comments"
    t.integer  "p_quality",           :default => 0
    t.integer  "p_efficiency",        :default => 0
    t.integer  "p_automation",        :default => 0
    t.text     "p_comments"
    t.integer  "i_designprocess",     :default => 0
    t.integer  "i_strategy",          :default => 0
    t.integer  "i_innovation",        :default => 0
    t.text     "i_comments"
    t.string   "judge_name"
    t.integer  "mechanical_design"
    t.integer  "programming"
    t.integer  "innovation_strategy"
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
    t.integer  "competition_id"
  end

end
