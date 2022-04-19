class AddCommentToCruftTrackerMethods < ActiveRecord::Migration[5.2]
  def change
    add_column :cruft_tracker_methods,
               :comment,
               :json,
               null: true,
               after: :invocations
  end
end
