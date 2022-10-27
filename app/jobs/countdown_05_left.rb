class Countdown05Left < ApplicationJob
  queue_as :countdown

  def perform(spotify_user_hash)
    spotify_user = RSpotify::User.new(spotify_user_hash)
    player = spotify_user.player
    player.play_track("spotify:track:5YQP0o0DKS8kjUs4lSUcK1")   # https://open.spotify.com/track/7hRwwjy1cmwGkzBnJlhtnY?si=54231d9da8b34933 # 5 minutes, 0:03-0:08
    player.seek(3000)
    sleep 5
    player.play_track("spotify:track:7rItgZqqlg6807KrBEDXrD") # suspense https://open.spotify.com/track/7rItgZqqlg6807KrBEDXrD?si=3809a86b77f04ec5
    player.repeat(state: 'track')
  end
end