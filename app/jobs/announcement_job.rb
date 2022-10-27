class AnnouncementJob < ApplicationJob
  queue_as :announcement

  def perform(spotify_user_hash)
    spotify_user = RSpotify::User.new(spotify_user_hash)
    player = spotify_user.player
    player.play_track("spotify:track:4KR5rxtAYDlW5hO7sAswzC") # horn
    sleep 2
    player.pause
  end
end