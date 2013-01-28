#load File.expand_path("../../lib/player.rb", File.dirname(__FILE__))
require 'player'

class SongsController < ApplicationController
  ROOT_DIR = File.expand_path("~/Music/iTunes/iTunes Media/Music")

  cattr_accessor :player

  N = 5
  def index
    @expand = (params[:expand] == "0" ? false : true)
    @dir = File.expand_path(params[:dir] || ROOT_DIR)
    @queue = player.queue.first(N).map{|x| x and File.basename(x)}.compact
  end

  def play_all
    @dir = File.expand_path(params[:dir] || ROOT_DIR)
    player.play_files(files(@dir))

    redirect_back_if_possible
  end

  def add
    @dir = File.expand_path(params[:dir])
    player.add_files(files(@dir))

    redirect_back_if_possible
  end

  def prev_song
    player.prev_song
    player.resume
    redirect_back_if_possible
  end

  def pause
    player.pause
    redirect_back_if_possible
  end

  def resume
    player.resume
    redirect_back_if_possible
  end

  def shuffle
    player.play_files(player.queue.shuffle)
    redirect_back_if_possible
  end

  def next_song
    player.next_song
    player.resume
    redirect_back_if_possible
  end

  def set_options
    session[:options] = params[:options]
    player.options = params[:options].to_s
    redirect_back_if_possible
  end
  
  private

  def files(path)
    if File.directory?(path)
      Dir["#{path}/**/*.{mp3,m4a}"]
    elsif File.exist?(path)
      [path]
    else
      []
    end
  end

  def player
    SongsController.player ||= Player::AFPlay.new(root_url())
  end

  def redirect_back_if_possible
    if request.env["HTTP_REFERER"]
      redirect_to :back
    else
      render text: "ok"
    end
  end
end
