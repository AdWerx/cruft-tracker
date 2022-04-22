# frozen_string_literal: true

module CruftTracker
  class CleanupUntrackedMethods < CruftTracker::ApplicationService
    private

    def execute
      CruftTracker::LogSuppressor.suppress_logging do
        CruftTracker::Method
          .where(deleted_at: nil)
          .each do |method|
            unless method.still_exists? && method.still_tracked?
              method.update(deleted_at: Time.current)
            end
          end
      end
    rescue StandardError
      # I'm actively ignoring all errors. Chances are, these are due to something like running rake
      # tasks in CI when the DB doesn't already exist.
    end
  end
end
