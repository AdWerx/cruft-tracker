require 'cruft_tracker/version'
require 'cruft_tracker/engine'

module CruftTracker
  # Your code goes here...

  def self.is_this_view_used?
    puts '>>>> is this view used?'
  end

  def self.is_this_method_used?(owner, method_name)
    CruftTracker::TrackMethod.run!(owner: owner, method_name: method_name)
  end
end
