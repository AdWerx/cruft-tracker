require 'cruft_tracker/version'
require 'cruft_tracker/engine'

module CruftTracker
  # Your code goes here...

  def self.is_this_view_used?
    puts '>>>> is this view used?'
  end

  def self.is_this_method_used?(owner, name, method_type: nil)
    CruftTracker::TrackMethod.run!(
      owner: owner,
      name: name,
      method_type: method_type
    )
  end
end
