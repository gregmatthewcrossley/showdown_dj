require 'rspotify/oauth'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :spotify, 
  Rails.application.credentials.dig(:spotify, :client_id),
  Rails.application.credentials.dig(:spotify, :client_secret), 
  scope: %w( 
    user-read-playback-state
    user-read-playback-position
    user-modify-playback-state
    user-read-currently-playing
    playlist-read-private
    playlist-read-collaborative
    user-library-read
  ).join(' ') # see: https://developer.spotify.com/documentation/general/guides/authorization/scopes/
end

OmniAuth.config.allowed_request_methods = [:post, :get]