class CreateCruftTrackerViews < ActiveRecord::Migration[5.2]
  def change
    create_table :cruft_tracker_views do |t|
      t.string :view, null: false
      t.integer :renders, null: false, default: 0
      t.json :comment, null: true
      t.datetime :deleted_at
      t.timestamps

      t.index :view, unique: true
    end
  end
end
