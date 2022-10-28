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
    if session[:vol_percent] >= 100
      session[:vol_percent] = 100
    else
      session[:vol_percent] += 10
    end
    begin
      player.volume [session[:vol_percent], 100].min
    rescue RestClient::Forbidden
      flash[:notice] = "This device can't change volume remotely."
    end
    redirect_to root_path
  end

  def volume_down
    if session[:vol_percent] < 0
      session[:vol_percent] = 100
    else
      session[:vol_percent] -= 10
    end
    begin
      player.volume [session[:vol_percent], 0].max
    rescue RestClient::Forbidden
      flash[:notice] = "This device can't change volume remotely."
    end
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
    save_playlist_position_parameters_if_playing
    AnnouncementJob.perform_later spotify_user.to_hash
    redirect_to root_path
  end

  def stop_announcement
    Delayed::Job.delete_all
    continue_playing_with playlist_position_parameters
    redirect_to root_path
  end

  def start_5_minute_countdown
    save_playlist_position_parameters_if_playing
    player.play_track("spotify:track:7rItgZqqlg6807KrBEDXrD") # suspense https://open.spotify.com/track/7rItgZqqlg6807KrBEDXrD?si=3809a86b77f04ec5
    player.repeat(state: 'track')
    # play the 1 minute soung clip in 4 minute and then play more intense suspensful music
    Countdown01LeftJob.set(wait: 4.minutes).perform_later spotify_user.to_hash
    # play the gong in 5 minutes and pause
    CountdownDoneJob.set(wait: 5.minutes).perform_later spotify_user.to_hash
    redirect_to root_path
  end

  def stop_5_minute_countdown
    Delayed::Job.delete_all
    continue_playing_with playlist_position_parameters
    redirect_to root_path
  end

  def start_10_minute_countdown
    save_playlist_position_parameters_if_playing
    player.play_track("spotify:track:7rItgZqqlg6807KrBEDXrD") # suspense https://open.spotify.com/track/7rItgZqqlg6807KrBEDXrD?si=3809a86b77f04ec5
    player.repeat(state: 'track')
    # play the 1 minute soung clip in 9 minute and then play more intense suspensful music
    Countdown01LeftJob.set(wait: 9.minutes).perform_later spotify_user.to_hash
    # play the gong in 10 minutes and pause
    CountdownDoneJob.set(wait: 10.minutes).perform_later spotify_user.to_hash
    redirect_to root_path
  end

  def stop_10_minute_countdown
    Delayed::Job.delete_all
    continue_playing_with playlist_position_parameters
    redirect_to root_path
  end

  def start_runway
    save_playlist_position_parameters_if_playing
    player.play_track("spotify:track:2FbTXBgXGvHJHuMAHxW9zd") # Runway https://open.spotify.com/track/2FbTXBgXGvHJHuMAHxW9zd?si=ccac2b7bb0074b33
    player.seek 43000
    player.repeat(state: 'track')
    redirect_to root_path
  end

  def stop_runway
    player.pause
    continue_playing_with playlist_position_parameters
    redirect_to root_path
  end

  def start_awards
    save_playlist_position_parameters_if_playing
    player.play_track("spotify:track:6A0mgcjDWaUmuD3WKK9jdA") # Pomp and Circumstance https://open.spotify.com/track/6A0mgcjDWaUmuD3WKK9jdA?si=aa38cfc990154416
    player.repeat(state: 'track')
    redirect_to root_path
  end

  def stop_awards
    player.pause
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

  def save_playlist_position_parameters_if_playing
    begin
      if player&.playing?
        save_playlist_position_parameters
      end
    rescue RestClient::NotFound
    end
  end
  
end
