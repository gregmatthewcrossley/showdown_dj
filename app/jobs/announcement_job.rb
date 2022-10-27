class AnnouncementJob < ApplicationJob
  queue_as :interruption

  def perform(party, spotify_user_hash, play_horn: false)
    if party.started?
      AnnouncementJob.perform_later(party, spotify_user_hash)
      if play_horn 
        spotify_user = RSpotify::User.new(spotify_user_hash)
        player = spotify_user.player
        player.play_track("spotify:track:4KR5rxtAYDlW5hO7sAswzC") # horn
        sleep 2
        player.pause
      end
    end
  end
end


# class KeepPartyGoingJob < ApplicationJob
#   queue_as :default

#   def perform(party, spotify_user_hash)
#     if party.started?
#       KeepPartyGoingJob.set(wait: 2.seconds).perform_later party, spotify_user_hash
#       spotify_user = RSpotify::User.new(spotify_user_hash)
#       player = spotify_user.player
#       if player.playing? 
#         # save current state
#         party.update!(
#           context_uri: player.context_uri,
#           uri:         player.currently_playing.uri,
#           position:    player.progress
#         )
#       else
#         # resume where we left off
#         player.play(nil, party.playlist_position_parameters)
#       end
#     end
#   end

# end