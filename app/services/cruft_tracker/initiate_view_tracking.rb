# frozen_string_literal: true

module CruftTracker
  class InitiateViewTracking < CruftTracker::ApplicationService
    VIEW_TRACKING_REGEX = /<%- CruftTracker\.is_this_view_used\?/

    array :pathnames do
      object class: ActionView::OptimizedFileSystemResolver
    end
    object :root_path, class: Pathname

    private

    def execute
      identify_tracked_views.each do |view_path|
        CruftTracker.is_this_view_used?(view_path.gsub(root_directory, ''))
      end
    end

    def root_directory
      "#{root_path.to_path}/"
    end

    def identify_tracked_views
      view_files.select do |view_file|
        File.readlines(view_file).grep(VIEW_TRACKING_REGEX).any?
      end
    end

    def view_files
      pathnames.map { |pathname| Dir.glob("#{pathname.path}/**/*.*") }.flatten
    end
  end
end
