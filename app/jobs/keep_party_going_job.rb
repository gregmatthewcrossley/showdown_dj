class KeepPartyGoingJob < ApplicationJob
  queue_as :default

  def perform(party, spotify_user_hash)
    if party.started?
      spotify_user = RSpotify::User.new(spotify_user_hash)
      player = spotify_user.player
      if player.playing? 
        # save current state
        party.update!(
          context_uri: player.context_uri,
          uri:         player.currently_playing.uri,
          position:    player.progress
        )
      else
        # resume where we left off
        player.play(nil, party.playlist_position_parameters)
      end
      KeepPartyGoingJob.set(wait: 1.seconds).perform_later(party, player)
    end
  end

end
