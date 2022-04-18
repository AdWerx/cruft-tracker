class CreateCruftTrackerMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :cruft_tracker_methods do |t|
      t.string :owner, null: false
      t.string :name, null: false
      t.string :method_type, null: false
      t.integer :invocations, null: false, default: 0
      t.datetime :deleted_at
      t.timestamps

      t.index :owner
      t.index :name
      t.index %i[owner name]
      t.index %i[owner name method_type], unique: true
    end
  end
end
