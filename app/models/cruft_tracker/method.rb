# frozen_string_literal: true

module CruftTracker
  class Method < ActiveRecord::Base
    has_many :cruft_tracker_backtraces,
             class_name: 'CruftTracker::Backtrace',
             as: :traceable
  end
end
