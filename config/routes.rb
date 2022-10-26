Rails.application.routes.draw do
  
  # Parties
  resources :parties do
    post :start
    post :interupt_with
    post :stop
  end
  root "parties#index"

  # Spotify API OAuth
  get '/auth/spotify/callback', to: 'application_controller#spotify_oauth_callback'

end
