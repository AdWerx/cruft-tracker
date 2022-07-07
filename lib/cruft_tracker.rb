require 'cruft_tracker/version'
require 'cruft_tracker/engine'
require 'cruft_tracker/registry'
require 'cruft_tracker/log_suppressor'

module CruftTracker
  class << self
    attr_accessor :config
  end

  def self.init(&block)
    self.config = Config.instance

    self.instance_eval(&block)
  end

  def self.is_this_view_used?(view, comment: nil)
    CruftTracker::TrackView.run!(view: view, comment: comment)
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

  class Config
    include Singleton

    DEFAULT_MAX_ARGUMENTS_VARIATIONS_PER_TRACKED_METHOD = 50
    DEFAULT_MAX_BACKTRACE_VARIATIONS_PER_TRACKED_METHOD = 50
    DEFAULT_MAX_VIEW_RENDERS_PER_VIEW = 50
    DEFAULT_MAX_RENDER_METADATA_VARIATIONS_PER_VIEW_RENDER = 50

    attr_accessor :max_argument_variations_per_tracked_method,
                  :max_backtrace_variations_per_tracked_method,
                  :max_view_renders_per_view,
                  :max_render_metadata_variations_per_view_render

    def initialize
      @max_argument_variations_per_tracked_method =
        DEFAULT_MAX_ARGUMENTS_VARIATIONS_PER_TRACKED_METHOD
      @max_backtrace_variations_per_tracked_method =
        DEFAULT_MAX_BACKTRACE_VARIATIONS_PER_TRACKED_METHOD
      @max_view_renders_per_view = DEFAULT_MAX_VIEW_RENDERS_PER_VIEW
      @max_render_metadata_variations_per_view_render =
        DEFAULT_MAX_RENDER_METADATA_VARIATIONS_PER_VIEW_RENDER
    end
  end
end
