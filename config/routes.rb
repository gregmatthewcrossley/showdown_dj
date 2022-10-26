Rails.application.routes.draw do
  
  # Parties
  resources :parties do
    member do
      post :start
      post :interupt_with
      post :stop
      post :skip
    end
  end
  root "parties#index"

  # Spotify API OAuth
  get '/auth/spotify/callback', to: 'application#spotify_oauth_callback'

end
