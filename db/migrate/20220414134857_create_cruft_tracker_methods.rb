class CreateCruftTrackerMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :cruft_tracker_methods do |t|
      t.string :owner_name, null: false
      t.string :method_name, null: false
      t.string :method_type, null: false
      t.integer :invocations, null: false, default: 0
      t.datetime :deleted_at
      t.timestamps

      t.index :owner_name
      t.index :method_name
      t.index %i[owner_name method_name]
      t.index %i[owner_name method_name method_type],
              unique: true,
              name: 'index_pc_on_owner_name_and_method_name_and_method_type'
    end
  end
end
