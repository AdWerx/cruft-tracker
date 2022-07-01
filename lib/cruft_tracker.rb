require 'cruft_tracker/version'
require 'cruft_tracker/engine'
require 'cruft_tracker/registry'
require 'cruft_tracker/log_suppressor'

module CruftTracker
  def self.init(&block)
    self.instance_eval(&block)
  end

  def self.is_this_view_used?(
    view,
    comment: nil,
    track_locals: nil
  )
    CruftTracker::TrackView.run!(
      view: view,
      comment: comment,
      locals_transformer: track_locals
    )
  end

  def self.record_view_metadata(track_variables: nil)
    CruftTracker::RecordViewRenderMetadata.run!(variables_transformer: track_variables)
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
