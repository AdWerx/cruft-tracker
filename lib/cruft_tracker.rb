require 'cruft_tracker/version'
require 'cruft_tracker/engine'
require 'cruft_tracker/registry'

module CruftTracker
  # Your code goes here...

  def self.is_this_view_used?
    puts '>>>> is this view used?'
  end

  def self.is_this_method_used?(
    owner,
    name,
    method_type: nil,
    comment: nil,
    track_arguments: nil
  )
    CruftTracker::TrackMethod.run!(
      owner: owner,
      name: name,
      method_type: method_type,
      comment: comment,
      arguments_transformer: track_arguments
    )
  end

  def self.are_any_of_these_methods_being_used?(owner, comment: nil)
    CruftTracker::TrackAllMethods.run!(owner: owner, comment: comment)
  end
end
