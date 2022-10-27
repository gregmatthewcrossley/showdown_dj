class Countdown01Left < ApplicationJob
  queue_as :countdown

  def perform(spotify_user_hash)
    spotify_user = RSpotify::User.new(spotify_user_hash)
    player = spotify_user.player
    player.play_track("spotify:track:5YQP0o0DKS8kjUs4lSUcK1")   # https://open.spotify.com/track/6kzlXSiHXvT9g6oRt1WAeO?si=1db48946ee1e4ee8 # 1 minute, 0:55-1:08
    player.seek(55000)
    sleep 13
    player.play_track("spotify:track:7rItgZqqlg6807KrBEDXrD") # suspense https://open.spotify.com/track/7rItgZqqlg6807KrBEDXrD?si=3809a86b77f04ec5
    player.repeat(state: 'track')
  end
end