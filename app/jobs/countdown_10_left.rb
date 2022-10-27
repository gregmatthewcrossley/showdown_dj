class Countdown10Left < ApplicationJob
  queue_as :countdown

  def perform(spotify_user_hash)
    spotify_user = RSpotify::User.new(spotify_user_hash)
    player = spotify_user.player
    player.play_track("spotify:track:5YQP0o0DKS8kjUs4lSUcK1") # https://open.spotify.com/track/5YQP0o0DKS8kjUs4lSUcK1?si=9fcb778cc60741fb # 10 minutes, 0:23-0:33
    player.seek(23000)
    sleep 10
    player.play_track("spotify:track:7rItgZqqlg6807KrBEDXrD") # suspense https://open.spotify.com/track/7rItgZqqlg6807KrBEDXrD?si=3809a86b77f04ec5
    player.repeat(state: 'track')
  end
end