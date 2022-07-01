# frozen_string_literal: true

module CruftTracker
  class View < ActiveRecord::Base
    has_many :backtraces, class_name: 'CruftTracker::Backtrace', as: :traceable
    has_many :render_metadata, class_name: 'CruftTracker::RenderMetadata'
  end
end
