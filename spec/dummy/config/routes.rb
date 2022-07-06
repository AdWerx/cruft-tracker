Rails.application.routes.draw do
  mount CruftTracker::Engine => '/cruft_tracker'

  get '/', to: 'main#show', as: :main
  resources :numbers, only: %i[index]
  get '/number/:index', to: 'numbers#present', as: 'number'
end
