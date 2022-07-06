module CruftTracker
  class Engine < ::Rails::Engine
    isolate_namespace CruftTracker

    config.after_initialize do
      CruftTracker::CleanupUntrackedMethods.run!
      CruftTracker::CleanupUntrackedViews.run!
    rescue StandardError
      # Swallow all errors to prevent initialization failures.
    end

    initializer 'local_helper.action_controller' do
      ActiveSupport.on_load :action_controller do
        helper CruftTracker::ApplicationHelper
      end
    end
  end
end
