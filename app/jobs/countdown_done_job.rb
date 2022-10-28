class CountdownDoneJob < ApplicationJob
  queue_as :countdown

  def perform(spotify_user_hash)
    spotify_user = RSpotify::User.new(spotify_user_hash)
    player = spotify_user.player
    player.play_track("spotify:track:1MUZnNIpLot0OxQ6Y1VUx9") # gong https://open.spotify.com/track/1MUZnNIpLot0OxQ6Y1VUx9?si=eb93d9ba0e714f1c 0:00=0:15
    sleep 15
    player.pause
  end
end