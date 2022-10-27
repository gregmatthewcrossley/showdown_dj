class AwardsJob < ApplicationJob
  queue_as :awards

  def perform(spotify_user_hash)
    spotify_user = RSpotify::User.new(spotify_user_hash)
    player = spotify_user.player
    player.play_track("spotify:track:6A0mgcjDWaUmuD3WKK9jdA") # Pomp and Circumstance https://open.spotify.com/track/6A0mgcjDWaUmuD3WKK9jdA?si=aa38cfc990154416
  end
end