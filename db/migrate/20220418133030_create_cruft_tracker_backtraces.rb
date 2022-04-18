class CreateCruftTrackerBacktraces < ActiveRecord::Migration[5.2]
  def change
    create_table :cruft_tracker_backtraces do |t|
      t.references :traceable,
                   polymorphic: true,
                   null: false,
                   index: {
                     name: 'index_pcbt_on_traceable_id_and_type'
                   }
      t.string :trace_hash, null: false, index: true
      t.json :trace, null: false
      t.integer :occurrences, null: false, index: true, default: 0
      t.timestamps

      t.index %i[traceable_id trace_hash],
              unique: true,
              name: 'index_pcbt_on_traceable_id_and_trace_hash'
    end
  end
end
