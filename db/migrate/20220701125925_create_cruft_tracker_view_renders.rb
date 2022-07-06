class CreateCruftTrackerViewRenders < ActiveRecord::Migration[5.2]
  def change
    create_table :cruft_tracker_view_renders do |t|
      t.references :view, null: false
      t.string :render_hash, null: false, index: true, unique: true
      t.string :controller, null: false, index: true
      t.string :endpoint, null: false, index: true
      t.string :route, null: false, index: true
      t.string :http_method, null: false, index: true
      t.json :render_stack, null: false
      t.integer :occurrences, null: false, index: true, default: 0

      t.timestamps

      t.index %i[view_id render_hash], unique: true
    end
  end
end
