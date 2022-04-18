# frozen_string_literal: true

module CruftTracker
  class Backtrace < ActiveRecord::Base
    belongs_to :traceable, polymorphic: true
  end
end
