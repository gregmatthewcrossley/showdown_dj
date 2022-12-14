Rails.application.routes.draw do
  
  get '/', to: 'application#control_panel'
  root        'application#control_panel'

  # Spotify API OAuth
  get '/auth/spotify/callback',      to: 'application#spotify_oauth_callback'

  # Interruptions
  post '/play_pause',                to: 'application#play_pause'
  post '/volume_up',                 to: 'application#volume_up'
  post '/volume_down',               to: 'application#volume_down'
  post '/skip',                      to: 'application#skip'
  post '/start_announcement',        to: 'application#start_announcement'
  post '/stop_announcement',         to: 'application#stop_announcement'
  post '/start_5_minute_countdown',  to: 'application#start_5_minute_countdown'
  post '/stop_5_minute_countdown',   to: 'application#stop_5_minute_countdown'
  post '/start_10_minute_countdown', to: 'application#start_10_minute_countdown'
  post '/stop_10_minute_countdown',  to: 'application#stop_10_minute_countdown'
  post '/start_runway',              to: 'application#start_runway'
  post '/stop_runway',               to: 'application#stop_runway'
  post '/start_awards',              to: 'application#start_awards'
  post '/stop_awards',               to: 'application#stop_awards'

end
