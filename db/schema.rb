# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091127212307) do

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
  end

  add_index "robot_scores", ["team_id"], :name => "index_robot_scores_on_team_id"

  create_table "teams", :force => true do |t|
    t.integer  "fll_number"
    t.string   "team_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "school"
    t.string   "town"
  end

end
