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

ActiveRecord::Schema.define(version: 2022_04_14_134857) do

  create_table "cruft_tracker_methods", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "owner_name", null: false
    t.string "method_name", null: false
    t.string "method_type", null: false
    t.integer "invocations", default: 0, null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["method_name"], name: "index_cruft_tracker_methods_on_method_name"
    t.index ["owner_name", "method_name", "method_type"], name: "index_pc_on_owner_name_and_method_name_and_method_type", unique: true
    t.index ["owner_name", "method_name"], name: "index_cruft_tracker_methods_on_owner_name_and_method_name"
    t.index ["owner_name"], name: "index_cruft_tracker_methods_on_owner_name"
  end

end
