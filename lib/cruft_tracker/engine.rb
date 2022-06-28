module CruftTracker
  class Engine < ::Rails::Engine
    isolate_namespace CruftTracker

    config.after_initialize do
      CruftTracker::CleanupUntrackedMethods.run!
      CruftTracker::InitiateViewTracking.run!(
        pathnames: ActionController::Base.view_paths,
        root_path: Rails.root
      )
    rescue StandardError
      # Swallow all errors to prevent initialization failures.
    end
  end
end
