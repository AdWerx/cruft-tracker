Rails.application.routes.draw do
  mount CruftTracker::Engine => "/cruft_tracker"

  get '/', to: 'main#show', as: :main
end
