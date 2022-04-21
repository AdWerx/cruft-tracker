class CreateCruftTrackerArguments < ActiveRecord::Migration[5.2]
  def change
    create_table :cruft_tracker_arguments do |t|
      t.references :method, null: false
      t.string :arguments_hash, null: false, index: true
      t.json :arguments, null: false
      t.integer :occurrences, null: false, index: true, default: 0
      t.timestamps

      t.index %i[method_id arguments_hash],
              unique: true,
              name: 'index_pca_on_method_id_and_arguments_hash'
    end
  end
end
