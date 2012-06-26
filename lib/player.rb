require 'open-uri'

class Player
  def initialize(ping_url=nil)
    if ping_url
      logger.info("[player] set ping_url to #{ping_url}")
      @ping_url = ping_url
    end
    @queue = []
    @thread = nil

    at_exit{
      kill_thread
    }
  end
  attr_reader :queue

  def current
    @queue.first
  end

  def play_files(list)
    logger.info "[player] play_files"
    @queue = list
    restart_thread
  end

  def play_wait
    logger.info "[player] play_wait"
    _play current
  end

  def pause
    logger.info "[player] pause"
    kill_thread
  end

  def resume
    logger.info "[player] resume"
    restart_thread
  end

  def prev_song
    logger.info "[player] prev"
    @queue.rotate!(-1)
  end
  
  def next_song
    logger.info "[player] succ"
    @queue.rotate!
  end

  private

  def restart_thread
    kill_thread
    @thread = Thread.new{
      loop do
        ping!
        play_wait
        next_song
      end
    }
  end

  def kill_thread
    @thread.kill if @thread
    _stop
  end


  # Issue HTTP GET to @ping_url.
  # Used for running afpray with pow,
  # because pow terminates the app in 15min
  # This prevents pow to restart afplay
  # (unless you have a song longer than 15min!).
  def ping!
    if @ping_url
      logger.info("[player] ping #{@ping_url}")
      s = open(@ping_url).read
      logger.info("[player] ping ok: read #{s.bytesize}")
    end
  end
    
  def logger; Rails.logger; end

  class AFPlay < Player
    def initialize(*args)
      super(*args)
      @process = nil
    end

    # Brocking API
    def _play(path)
      logger.info "[player] play #{path}"
      @process = ChildProcess.build("afplay", path)
      @process.io.inherit!
      @process.start
      @process.wait
    end

    def _stop
      @process.stop if @process && @process.alive?
    end

  end
end
