#load File.expand_path("../../lib/player.rb", File.dirname(__FILE__))
require 'player'

class SongsController < ApplicationController
  ROOT_DIR = "/Users/yhara/Music/iTunes/iTunes Music/"

  cattr_accessor :player

  N = 5
  def index
    @dir = File.expand_path(params[:dir] || ROOT_DIR)
    @queue = player.queue.first(N).map{|x| x and File.basename(x)}
    @queue.push("...") if player.queue.size > N
  end

  def play_all
    @dir = File.expand_path(params[:dir] || ROOT_DIR)
    player.play_files(Dir["#{@dir}/**/*.{mp3,m4a}"])

    redirect_to :back
  end

  def prev_song
    player.prev_song
    player.resume
    redirect_to :back
  end

  def pause
    player.pause
    redirect_to :back
  end

  def resume
    player.resume
    redirect_to :back
  end

  def next_song
    player.next_song
    player.resume
    redirect_to :back
  end
  
  private

  def player
    SongsController.player ||= Player::AFPlay.new(root_url())
  end
end
