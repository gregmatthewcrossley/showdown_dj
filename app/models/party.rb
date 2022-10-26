class Party < ApplicationRecord
  # status enum
  enum status: { 
    stopped: 0, # default
    started: 1,
    interrupted: 2
  }

  before_save :parse_playlist_uid

  def start(spotify_user: )
    # start playing the beginning of the playlist
    player = spotify_user.player
    player.play_context(nil, "spotify:playlist:#{playlist_uid}")
    # save state
    update!(
      context_uri: player.context_uri,
      uri:         player.currently_playing.uri,
      position:    player.progress
    )
    # set the party to :started
    self.status = :started
    self.save!
    # schedule a job to keep the party going
    KeepPartyGoingJob.perform_later self, spotify_user.to_hash
  end

  def stop(spotify_user: )
    self.status = :stopped
    self.save!
    spotify_user.player.pause
  end

  def skip(spotify_user: )
    player = spotify_user.player
    player.next
  end

  def playlist_position_parameters
    {
      'context_uri' => context_uri || playlist_uid, 
      'offset' => {
        'uri' => uri || nil,
      },
      'position_ms' => position || 0
    }
  end

  private

  def parse_playlist_uid
    return unless playlist_uid && playlist_uid.include?('https://open.spotify.com/playlist/')
    self.playlist_uid = playlist_uid
      .split('https://open.spotify.com/playlist/').last
      .split('?si=').first
  end

end
