class Party < ApplicationRecord
  # status enum
  enum status: { 
    stopped: 0, # default
    started: 1,
    interrupted: 2
  }

  before_save :parse_playlist_uid

  private

  def parse_playlist_uid
    return unless playlist_uid && playlist_uid.include?('https://open.spotify.com/playlist/')
    self.playlist_uid = playlist_uid
      .split('https://open.spotify.com/playlist/').last
      .split('?si=').first
  end

end
