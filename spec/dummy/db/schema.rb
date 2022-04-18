# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_04_18_133030) do

  create_table "cruft_tracker_backtraces", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "traceable_type", null: false
    t.bigint "traceable_id", null: false
    t.string "trace_hash", null: false
    t.json "trace", null: false
    t.integer "occurrences", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["occurrences"], name: "index_cruft_tracker_backtraces_on_occurrences"
    t.index ["trace_hash"], name: "index_cruft_tracker_backtraces_on_trace_hash"
    t.index ["traceable_id", "trace_hash"], name: "index_pcbt_on_traceable_id_and_trace_hash", unique: true
    t.index ["traceable_type", "traceable_id"], name: "index_pcbt_on_traceable_id_and_type"
  end

  create_table "cruft_tracker_methods", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "owner", null: false
    t.string "name", null: false
    t.string "method_type", null: false
    t.integer "invocations", default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cruft_tracker_methods_on_name"
    t.index ["owner", "name", "method_type"], name: "index_cruft_tracker_methods_on_owner_and_name_and_method_type", unique: true
    t.index ["owner", "name"], name: "index_cruft_tracker_methods_on_owner_and_name"
    t.index ["owner"], name: "index_cruft_tracker_methods_on_owner"
  end

end
