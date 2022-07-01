# frozen_string_literal: true

# TODO: delete me?
module CruftTracker
  class InitiateViewTracking < CruftTracker::ApplicationService
    VIEW_TRACKING_REGEX = /<%- CruftTracker\.is_this_view_used\?/

    private

    array :pathnames do
      object class: ActionView::OptimizedFileSystemResolver
    end

    def execute
      identify_tracked_views.each do |view_path|
        CruftTracker.is_this_view_used?(view_path)
      end
    end

    def identify_tracked_views
      view_files.select do |view_file|
        File.readlines(view_file).grep(VIEW_TRACKING_REGEX).any?
      end
    end

    def view_files
      pathnames.map { |pathname| Dir.glob("#{pathname.to_path}/**/*.*") }.flatten
    end
  end
end
