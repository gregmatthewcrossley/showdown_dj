class Countdown01LeftJob < ApplicationJob
  queue_as :countdown

  def perform(spotify_user_hash)
    spotify_user = RSpotify::User.new(spotify_user_hash)
    player = spotify_user.player
    player.play_track("spotify:track:6kzlXSiHXvT9g6oRt1WAeO")   # https://open.spotify.com/track/6kzlXSiHXvT9g6oRt1WAeO?si=1db48946ee1e4ee8 # 1 minute, 0:55-1:08
    player.seek(55000)
    sleep 13
    player.play_track("spotify:track:0RZIfTXmwayTJprBbgRGHB") # even more suspensful suspense https://open.spotify.com/track/0RZIfTXmwayTJprBbgRGHB?si=a8906e89fbad46c9
    player.repeat(state: 'track')
  end
end