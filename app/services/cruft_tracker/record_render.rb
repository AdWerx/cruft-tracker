# frozen_string_literal: true

module CruftTracker
  # TODO: test me.
  class RecordRender < CruftTracker::ApplicationService
    record :view, class: CruftTracker::View

    def execute
      CruftTracker::LogSuppressor.suppress_logging { increment_renders }
    end

    def increment_renders
      view.update(renders: view.reload.renders + 1)
    end
  end
end
