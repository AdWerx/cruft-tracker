class CreateRenderMetadata < ActiveRecord::Migration[5.2]
  def change
    create_table :cruft_tracker_render_metadata do |t|
      t.references :view_render, null: false
      t.string :metadata_hash, null: false
      t.json :metadata, null: false
      t.integer :occurrences, null: false, index: true, default: 0
      t.timestamps

      t.index :metadata_hash, unique: true
    end
  end
end
