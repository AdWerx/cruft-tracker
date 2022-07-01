module CruftTracker
  module ApplicationHelper
    def record_cruft_tracker_view_metadata(variables = nil)
      CruftTracker::RecordViewRender.run(
        view: cruft_tracker_view,
        controller: controller.class.to_s,
        endpoint: action_name,
        route: route_path,
        render_stack: render_stack
      )
    # rescue StandardError => e
    #   binding.pry
      # Swallow errors
    end

    private

    def cruft_tracker_view
      # binding.pry
      CruftTracker::View.find_by(view: render_stack.first.path.gsub(/#{Rails.root}\//, ""))
    end

    def route_path
      _routes.router.recognize(request) do |route, _|
        return route.path.spec.to_s
      end

      nil
    end

    def paths_to_views
      @paths_to_views ||= view_paths.map { |view_path| view_path.to_path }
    end

    def render_stack
        caller_locations.select do |caller_location|
          paths_to_views.any? do |path_for_view|
            caller_location.path.match?(/^#{path_for_view}\//)
          end
        end
    end
  end
end
