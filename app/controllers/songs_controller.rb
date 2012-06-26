#load File.expand_path("../../lib/player.rb", File.dirname(__FILE__))
require 'player'

class SongsController < ApplicationController
  ROOT_DIR = "/Users/yhara/Music/iTunes/iTunes Music/"

  cattr_accessor :player

  N = 5
  def index
    @expand = params[:expand]
    @dir = File.expand_path(params[:dir] || ROOT_DIR)
    @queue = player.queue.first(N).map{|x| x and File.basename(x)}
    @queue.push("...") if player.queue.size > N
  end

  def play_all
    @dir = File.expand_path(params[:dir] || ROOT_DIR)
    player.play_files(Dir["#{@dir}/**/*.{mp3,m4a}"])

    redirect_back_or_index
  end

  def prev_song
    player.prev_song
    player.resume
    redirect_back_or_index
  end

  def pause
    player.pause
    redirect_back_or_index
  end

  def resume
    player.resume
    redirect_back_or_index
  end

  def next_song
    player.next_song
    player.resume
    redirect_back_or_index
  end
  
  private

  def player
    SongsController.player ||= Player::AFPlay.new(root_url())
  end

  def redirect_back_or_index
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to action: index
  end
end
