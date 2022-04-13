CruftTracker::Engine.routes.draw do
  resources :methods, only: %i[index]
end
