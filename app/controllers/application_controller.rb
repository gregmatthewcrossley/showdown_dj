class ApplicationController < ActionController::Base
  before_action :initialize_spotify_user_and_player, except: [:spotify_oauth_callback]

  def spotify_oauth_callback
    session[:spotify_user] = RSpotify::User.new(request.env['omniauth.auth']).to_hash
    redirect_to root_path
  end

  private

  def initialize_spotify_user_and_player
    spotify_user
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
end
