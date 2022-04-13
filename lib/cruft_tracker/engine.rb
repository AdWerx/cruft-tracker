module CruftTracker
  class Engine < ::Rails::Engine
    isolate_namespace CruftTracker

    # initializer 'cruft_tracker.action_controller' do |app|
    #   ActiveSupport.on_load(:action_controller) do
    #     ::ActionController::Base.helper(CruftTracker::ApplicationHelper)
    #   end
    # end

  end
end
