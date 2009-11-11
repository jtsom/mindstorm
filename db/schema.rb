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

ActiveRecord::Schema.define(:version => 20091027030807) do

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

  create_table "teams", :force => true do |t|
    t.integer  "fll_number"
    t.string   "team_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "school"
    t.string   "town"
    t.integer  "project_score"
    t.integer  "technical_score"
  end

end
