require 'open-uri'

class Player
  def initialize(ping_url=nil)
    if ping_url
      logger.info("[player] set ping_url to #{ping_url}")
      @ping_url = ping_url
    end
    @queue = []
  end
  attr_reader :queue

  def play_files(list=nil)
    @queue = list if list
    stop
    Thread.new{
      loop do
        path = @queue.shift
        @queue.push path
        ping!
        play path, wait: true
        break if @stopped
      end
    }
  end
  
  def pause
    logger.info "[player] pause"
    @stopped = true
    stop
  end

  def resume
    logger.info "[player] resume"
    play_files
  end

  private

  # Issue HTTP GET to @ping_url.
  # Used for running afpray with pow,
  # because pow terminates the app in 15min
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
      @stopped = true
    end

    def play(path, opt={})
      logger.info "[player] play #{path}"
      @stopped = false
      stop
      @process = ChildProcess.build("afplay", path)
      @process.io.inherit!
      @process.start
      @process.wait if opt[:wait]
    end

    def stop
      @process.stop if @process && @process.alive?
    end

  end
end
