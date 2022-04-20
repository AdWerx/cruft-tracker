module CruftTracker
  class Engine < ::Rails::Engine
    isolate_namespace CruftTracker

    config.after_initialize do
      CruftTracker::CleanupUntrackedMethods.run!
    rescue StandardError
      # Swallow all errors to prevent initialization failures.
    end

    # initializer 'cruft_tracker.action_controller' do |app|
    #   ActiveSupport.on_load(:action_controller) do
    #     ::ActionController::Base.helper(CruftTracker::ApplicationHelper)
    #   end
    # end
  end
end
