# frozen_string_literal: true

module CruftTracker
  class Method < ActiveRecord::Base
    has_many :backtraces, class_name: 'CruftTracker::Backtrace', as: :traceable
    has_many :arguments, class_name: 'CruftTracker::Argument'
  end
end
