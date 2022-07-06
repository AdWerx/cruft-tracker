# frozen_string_literal: true

module CruftTracker
  class View < ActiveRecord::Base
    has_many :backtraces, class_name: 'CruftTracker::Backtrace', as: :traceable
    has_many :view_renders, class_name: 'CruftTracker::ViewRender'

    def still_exists?
      File.exist?(absolute_path)
    end

    def still_tracked?
      return true if CruftTracker::Registry.include?(self)
      return true if File.read(absolute_path).match?(/record_cruft_tracker_view_render/)

      false
    end

    private

    def absolute_path
      "#{Rails.root}/#{view}"
    end
  end
end
