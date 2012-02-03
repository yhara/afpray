require 'player'

class SongsController < ApplicationController
  ROOT_DIR = "/Users/yhara/Music/iTunes/iTunes Music/"

  @@player = Player::AFPlay.new

  def index
    @dir = File.expand_path(params[:dir] || ROOT_DIR)
    @id = @@player.object_id
    @queue = @@player.queue.map{|x| x and File.basename(x)}
  end

  def play
    @dir = File.expand_path(params[:dir] || ROOT_DIR)
    @@player.play_files(Dir["#{@dir}/*.mp3"])

    redirect_to :back
  end

  def pause
    @@player.pause

    redirect_to :back
  end

  def resume
    @@player.resume

    redirect_to :back
  end
end
