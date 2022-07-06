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

ActiveRecord::Schema.define(version: 2022_07_05_152409) do

  create_table "cruft_tracker_arguments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "method_id", null: false
    t.string "arguments_hash", null: false
    t.json "arguments", null: false
    t.integer "occurrences", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arguments_hash"], name: "index_cruft_tracker_arguments_on_arguments_hash"
    t.index ["method_id", "arguments_hash"], name: "index_pca_on_method_id_and_arguments_hash", unique: true
    t.index ["method_id"], name: "index_cruft_tracker_arguments_on_method_id"
    t.index ["occurrences"], name: "index_cruft_tracker_arguments_on_occurrences"
  end

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
    t.json "comment"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_cruft_tracker_methods_on_name"
    t.index ["owner", "name", "method_type"], name: "index_cruft_tracker_methods_on_owner_and_name_and_method_type", unique: true
    t.index ["owner", "name"], name: "index_cruft_tracker_methods_on_owner_and_name"
    t.index ["owner"], name: "index_cruft_tracker_methods_on_owner"
  end

  create_table "cruft_tracker_render_metadata", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "view_render_id", null: false
    t.string "metadata_hash", null: false
    t.json "metadata", null: false
    t.integer "occurrences", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["metadata_hash"], name: "index_cruft_tracker_render_metadata_on_metadata_hash", unique: true
    t.index ["occurrences"], name: "index_cruft_tracker_render_metadata_on_occurrences"
    t.index ["view_render_id"], name: "index_cruft_tracker_render_metadata_on_view_render_id"
  end

  create_table "cruft_tracker_view_renders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.bigint "view_id", null: false
    t.string "render_hash", null: false
    t.string "controller", null: false
    t.string "endpoint", null: false
    t.string "route", null: false
    t.string "http_method", null: false
    t.json "render_stack", null: false
    t.integer "occurrences", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["controller"], name: "index_cruft_tracker_view_renders_on_controller"
    t.index ["endpoint"], name: "index_cruft_tracker_view_renders_on_endpoint"
    t.index ["http_method"], name: "index_cruft_tracker_view_renders_on_http_method"
    t.index ["occurrences"], name: "index_cruft_tracker_view_renders_on_occurrences"
    t.index ["render_hash"], name: "index_cruft_tracker_view_renders_on_render_hash"
    t.index ["route"], name: "index_cruft_tracker_view_renders_on_route"
    t.index ["view_id", "render_hash"], name: "index_cruft_tracker_view_renders_on_view_id_and_render_hash", unique: true
    t.index ["view_id"], name: "index_cruft_tracker_view_renders_on_view_id"
  end

  create_table "cruft_tracker_views", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3", force: :cascade do |t|
    t.string "view", null: false
    t.integer "renders", default: 0, null: false
    t.json "comment"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["view"], name: "index_cruft_tracker_views_on_view", unique: true
  end

end
