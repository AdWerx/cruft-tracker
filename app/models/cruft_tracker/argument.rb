# frozen_string_literal: true

module CruftTracker
  class Argument < ActiveRecord::Base
    belongs_to :method
  end
end
