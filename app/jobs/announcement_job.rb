class AnnouncementJob < ApplicationJob
  queue_as :announcement

  def perform(spotify_user_hash)
    spotify_user = RSpotify::User.new(spotify_user_hash)
    player = spotify_user.player
    player.play_track("spotify:track:18ehTdvJd1nsYzJqhsa09u") # trumpet https://open.spotify.com/track/18ehTdvJd1nsYzJqhsa09u?si=fe6a472b7b454cff
    sleep 7
    player.pause
  end
end