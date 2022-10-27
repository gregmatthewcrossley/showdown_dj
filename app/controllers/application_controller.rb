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
      if player.playing?
        player.pause
      else
        player.play
      end
    rescue RestClient::NotFound
      flash[:notice] = "Couldn't play/pause. Try playing something first"
    end
    redirect_to root_path
  end

  def skip
    begin
      if player.playing?
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
    player.play(nil, playlist_position_parameters)
  end

  def pause_if_playing_and_save_playlist_position_parameters
    begin
      if player.playing?
        save_playlist_position_parameters
        player.pause
      end
    rescue RestClient::NotFound
    end
  end
  
end


# class PartiesController < ApplicationController
#   before_action :set_party, except: %i[ index new ]

#   def start
#     unless @party.start(spotify_user: spotify_user)
#       flash[:error] = "Couldn't start - try starting Spotify your self."
#     end
#   end

#   def interupt_with
#     @party.interupt_with
#   end

#   def stop
#     @party.stop(spotify_user: spotify_user)
#   end

#   def skip
#     @party.skip(spotify_user: spotify_user)
#   end

#   def start_announcement
#     @party.start_announcement(spotify_user: spotify_user)
#   end

#   def stop_announcement
#     @party.stop_announcement(spotify_user: spotify_user)
#   end

#   def start_15_minute_countdown
#     @party.start_15_minute_countdown(spotify_user: spotify_user)
#   end

#   def stop_15_minute_countdown
#     @party.stop_15_minute_countdown(spotify_user: spotify_user)
#   end

#   def start_awards
#     @party.start_awards(spotify_user: spotify_user)
#   end

#   def stop_awards
#     @party.stop_awards(spotify_user: spotify_user)
#   end

#   # GET /parties or /parties.json
#   def index
#     @parties = Party.all
#   end

#   # GET /parties/1 or /parties/1.json
#   def show
#   end

#   # GET /parties/new
#   def new
#     @party = Party.new
#   end

#   # GET /parties/1/edit
#   def edit
#   end

#   # POST /parties or /parties.json
#   def create
#     @party = Party.new(party_params)

#     respond_to do |format|
#       if @party.save
#         format.html { redirect_to party_url(@party), notice: "Party was successfully created." }
#         format.json { render :show, status: :created, location: @party }
#       else
#         format.html { render :new, status: :unprocessable_entity }
#         format.json { render json: @party.errors, status: :unprocessable_entity }
#       end
#     end
#   end

#   # PATCH/PUT /parties/1 or /parties/1.json
#   def update
#     respond_to do |format|
#       if @party.update(party_params)
#         format.html { redirect_to party_url(@party), notice: "Party was successfully updated." }
#         format.json { render :show, status: :ok, location: @party }
#       else
#         format.html { render :edit, status: :unprocessable_entity }
#         format.json { render json: @party.errors, status: :unprocessable_entity }
#       end
#     end
#   end

#   # DELETE /parties/1 or /parties/1.json
#   def destroy
#     @party.destroy

#     respond_to do |format|
#       format.html { redirect_to parties_url, notice: "Party was successfully destroyed." }
#       format.json { head :no_content }
#     end
#   end

#   private
#     # Use callbacks to share common setup or constraints between actions.
#     def set_party
#       @party = Party.find(params[:id])
#     end

#     # Only allow a list of trusted parameters through.
#     def party_params
#       params.require(:party).permit(:name, :playlist_uid, :status)
#     end
# end







# class Party < ApplicationRecord
#   # status enum
#   enum status: { 
#     stopped: 0, # default
#     started: 1,
#     interrupted: 2
#   }

#   before_save :parse_playlist_uid

#   def start(spotify_user: )
#     # start playing the beginning of the playlist
#     player = spotify_user.player
#     begin
#       player.play_context(nil, "spotify:playlist:#{playlist_uid}")
#     rescue RestClient::NotFound
#       return false
#     end
#     # save state
#     update!(
#       context_uri: player.context_uri,
#       uri:         player.currently_playing.uri,
#       position:    player.progress
#     )
#     # set the party to :started
#     self.status = :started
#     self.save!
#     # schedule a job to keep the party going
#     KeepPartyGoingJob.perform_later self, spotify_user.to_hash
#   end

#   def stop(spotify_user: )
#     self.status = :stopped
#     self.save!
#     spotify_user.player.pause
#   end

#   def skip(spotify_user: )
#     player = spotify_user.player
#     player.next
#   end

#   def start_announcement(spotify_user: )
#     # enqueue a job that plays the horn sound once,
#     # then re-enqueues itself to play nothing forever
#     AnnouncementJob.perform_later self, spotify_user.to_hash, play_horn: true
#   end

#   def stop_announcement(spotify_user: )
#     # empty the AnnouncementJob queue
#     Delayed::Job.where('handler LIKE ?', '%AnnouncementJob%').destroy_all
#   end

#   def start_15_minute_countdown(spotify_user: )
    
#   end

#   def stop_15_minute_countdown(spotify_user: )
   
#   end

#   def start_awards(spotify_user: )
    
#   end

#   def stop_awards(spotify_user: )
    
#   end

#   def playlist_position_parameters
#     {
#       'context_uri' => context_uri || playlist_uid, 
#       'offset' => {
#         'uri' => uri || nil,
#       },
#       'position_ms' => position || 0
#     }
#   end

#   private

#   def parse_playlist_uid
#     return unless playlist_uid && playlist_uid.include?('https://open.spotify.com/playlist/')
#     self.playlist_uid = playlist_uid
#       .split('https://open.spotify.com/playlist/').last
#       .split('?si=').first
#   end

# end
