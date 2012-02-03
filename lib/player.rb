class Player
  def initialize
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
    
  def logger; Rails.logger; end

  class AFPlay < Player
    def initialize
      super
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
