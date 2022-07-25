module CruftTracker
  class Engine < ::Rails::Engine
    isolate_namespace CruftTracker

    config.after_initialize do
      ActionController::Base.helper CruftTracker::ApplicationHelper
      CruftTracker::CleanupUntrackedMethods.run!
      CruftTracker::CleanupUntrackedViews.run!
    rescue StandardError
      # Swallow all errors to prevent initialization failures.
    end


  end
end
