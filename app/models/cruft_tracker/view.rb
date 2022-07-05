# frozen_string_literal: true

module CruftTracker
  class View < ActiveRecord::Base
    has_many :backtraces, class_name: 'CruftTracker::Backtrace', as: :traceable
    has_many :view_renders, class_name: 'CruftTracker::ViewRender'
  end
end
