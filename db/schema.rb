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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141019195353) do

  create_table "games", force: :cascade do |t|
    t.text     "game_type"
    t.date     "date"
    t.text     "home_team"
    t.text     "home_team_abv"
    t.integer  "home_score"
    t.text     "home_url"
    t.text     "home_players"
    t.text     "away_team"
    t.text     "away_team_abv"
    t.integer  "away_score"
    t.text     "away_url"
    t.text     "away_players"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "games", ["away_players"], name: "index_games_on_away_players"
  add_index "games", ["away_team"], name: "index_games_on_away_team"
  add_index "games", ["date"], name: "index_games_on_date"
  add_index "games", ["home_players"], name: "index_games_on_home_players"
  add_index "games", ["home_team"], name: "index_games_on_home_team"

  create_table "links", force: :cascade do |t|
    t.text     "name"
    t.text     "href"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "videos", force: :cascade do |t|
    t.integer  "game_id",                         null: false
    t.text     "name"
    t.text     "video_code"
    t.integer  "renba_views",     default: 1,     null: false
    t.integer  "problem_reports", default: 1,     null: false
    t.text     "license"
    t.datetime "published_at"
    t.integer  "views",           default: 1,     null: false
    t.integer  "likes",           default: 1,     null: false
    t.integer  "dislikes",        default: 1,     null: false
    t.boolean  "new",             default: false, null: false
    t.boolean  "hd",              default: false, null: false
    t.boolean  "highlights",      default: false, null: false
    t.text     "description"
    t.text     "length"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "videos", ["created_at"], name: "index_videos_on_created_at"
  add_index "videos", ["name"], name: "index_videos_on_name"
  add_index "videos", ["published_at"], name: "index_videos_on_published_at"
  add_index "videos", ["video_code"], name: "index_videos_on_video_code"

end
