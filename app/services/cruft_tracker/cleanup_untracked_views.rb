# frozen_string_literal: true

module CruftTracker
  class CleanupUntrackedViews < CruftTracker::ApplicationService
    private

    def execute
      CruftTracker::LogSuppressor.suppress_logging do
        CruftTracker::View
          .where(deleted_at: nil)
          .each do |view|
            unless view.still_exists? && view.still_tracked?
              view.update(deleted_at: Time.current)
            end
          end
      end
    rescue StandardError
      # I'm actively ignoring all errors. Chances are, these are due to something like running rake
      # tasks in CI when the DB doesn't already exist.
    end
  end
end
