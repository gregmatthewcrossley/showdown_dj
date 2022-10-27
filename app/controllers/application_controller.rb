class ApplicationController < ActionController::Base
  before_action :initialize_spotify_user_and_player, except: [:spotify_oauth_callback]

  def spotify_oauth_callback
    session[:spotify_user] = RSpotify::User.new(request.env['omniauth.auth']).to_hash
    redirect_to root_path
  end

  def control_panel
    # root path
  end

  def play_pause
    begin
      if player&.playing?
        player.pause
      else
        player.play
      end
    rescue RestClient::NotFound
      flash[:notice] = "Couldn't play/pause. Try playing something first"
    end
    redirect_to root_path
  end

  def volume_up
    unless session[:vol_percent] >= 100
      session[:vol_percent] += 10
    end
    player.volume session[:vol_percent]
    redirect_to root_path
  end

  def volume_down
    unless session[:vol_percent] <= 0
      session[:vol_percent] -= 10
    end
    player.volume session[:vol_percent]
    redirect_to root_path
  end

  def skip
    begin
      if player&.playing?
        player.next
      else
        flash[:notice] = "Nothing is playing right now."
      end
    rescue RestClient::NotFound
      flash[:notice] = "Couldn't skip. Try playing something first."
    end
    redirect_to root_path
  end

  def start_announcement
    pause_if_playing_and_save_playlist_position_parameters
    AnnouncementJob.perform_later spotify_user.to_hash
    redirect_to root_path
  end

  def stop_announcement
    Delayed::Job.delete_all
    continue_playing_with playlist_position_parameters
    redirect_to root_path
  end

  def start_15_minute_countdown
    pause_if_playing_and_save_playlist_position_parameters
    player.play_track("spotify:track:7rItgZqqlg6807KrBEDXrD") # suspense https://open.spotify.com/track/7rItgZqqlg6807KrBEDXrD?si=3809a86b77f04ec5
    player.repeat(state: 'track')
    # play the 10 minute sound in 5 minutes and resume suspense music
    Countdown10Left.set(wait: 5.minutes).perform_later spotify_user.to_hash
    # play the 5 minutes sound in 10 minutes and resume suspense music
    Countdown05Left.set(wait: 10.minutes).perform_later spotify_user.to_hash
    # play the 1 minute sound in 14 minute and resume suspense music
    Countdown01Left.set(wait: 14.minutes).perform_later spotify_user.to_hash
    # play the 10 second sound in 14:50 seconds and resume suspense music
    Countdown10sLeft.set(wait: 14.minutes + 50.seconds).perform_later spotify_user.to_hash
    # play the gong in 15 minutes and pause
    redirect_to root_path
  end

  def stop_15_minute_countdown
    Delayed::Job.delete_all
    continue_playing_with playlist_position_parameters
    redirect_to root_path
  end

  def start_awards
    pause_if_playing_and_save_playlist_position_parameters
    AwardsJob.perform_later spotify_user.to_hash
    redirect_to root_path
  end

  def stop_awards
    Delayed::Job.delete_all
    continue_playing_with playlist_position_parameters
    redirect_to root_path
  end
  
  private

  def initialize_spotify_user_and_player
    spotify_user
    session[:vol_percent] = 50 if session[:vol_percent].nil?
    player
  end

  def spotify_user
    return nil unless session[:spotify_user]
    @spotify_user ||= RSpotify::User.new(session[:spotify_user])
  end

  def player
    return nil unless session[:spotify_user]
    @player ||= spotify_user&.player
  end

  def playlist_position_parameters
    session[:playlist_position_parameters]
  end

  def save_playlist_position_parameters
    session[:playlist_position_parameters] = {
      'context_uri' => player.context_uri,
      'offset' => {
        'uri' => player.currently_playing.uri,
      },
      'position_ms' => player.progress
    }
  end

  def continue_playing_with(playlist_position_parameters)
    if session[:playlist_position_parameters]['context_uri'].nil?
      player.play_context(nil,"spotify:playlist:37i9dQZF1DXa2PvUpywmrr") # party playlist: https://open.spotify.com/playlist/37i9dQZF1DXa2PvUpywmrr?si=b4f2b77b83e5484a
      flash[:notice] = "Nothing was playing prior, playing 'Party'."
    else
      player.play(nil, playlist_position_parameters)
    end
  end

  def pause_if_playing_and_save_playlist_position_parameters
    begin
      if player&.playing?
        save_playlist_position_parameters
        player.pause
      end
    rescue RestClient::NotFound
    end
  end
  
end
