class CreateCruftTrackerBacktraces < ActiveRecord::Migration[5.2]
  def change
    create_table :cruft_tracker_backtraces do |t|
      t.references :traceable,
                   polymorphic: true,
                   null: false,
                   index: {
                     name: 'index_pcbt_on_traceable_id_and_type'
                   }
      t.string :hash, null: false, index: true
      t.json :trace, null: false
      t.integer :occurrences, null: false, index: true, default: 0
      t.timestamps

      t.index %i[traceable_id hash],
              unique: true,
              name: 'index_pcbt_on_traceable_id_and_hash'
    end
  end
end
