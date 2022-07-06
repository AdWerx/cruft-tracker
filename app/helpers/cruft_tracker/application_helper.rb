module CruftTracker
  module ApplicationHelper
    def record_cruft_tracker_view_render(metadata = {})
      CruftTracker::RecordViewRender.run!(
        view: cruft_tracker_view,
        controller: controller.class.to_s,
        endpoint: action_name,
        route: route_path,
        render_stack: render_stack,
        metadata: metadata
      )
    rescue StandardError
      # Swallow errors
    end

    private

    def cruft_tracker_view
      path = render_stack.first[:path].gsub(/#{Rails.root}\//, "")
      view = CruftTracker::View.find_by(view: path)

      return view if view.present?

      CruftTracker::TrackView.run!(view: path)
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
      end.map do |location|
        {
          path: location.path,
          label: location.label,
          base_label: location.base_label,
          lineno: location.lineno
        }
      end
    end
  end
end
