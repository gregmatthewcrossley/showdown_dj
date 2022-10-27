class Countdown10sLeft < ApplicationJob
  queue_as :countdown

  def perform(spotify_user_hash)
    spotify_user = RSpotify::User.new(spotify_user_hash)
    player = spotify_user.player
    player.play_track("spotify:track:5YQP0o0DKS8kjUs4lSUcK1")     # https://open.spotify.com/track/72Z17vmmeQKAg8bptWvpVG?si=82a4acf61ca84fbe # 10 second, 0:49-1:14
    player.seek(49000)
    sleep 25
    player.play_track("spotify:track:7rItgZqqlg6807KrBEDXrD") # gong https://open.spotify.com/track/1MUZnNIpLot0OxQ6Y1VUx9?si=c5179b8327914ae4 0:00=0:15
    sleep 15
    player.pause
  end
end