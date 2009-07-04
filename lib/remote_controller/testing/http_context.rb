require 'webrick'
include WEBrick

class RemoteController::Testing::HttpContext
  WAIT_TIMEOUT = 5
  
  def initialize(port)
    @port = port
    
    @monitor = Monitor.new
    @cond = @monitor.new_cond
    
    @completed = false
    @error = nil
  end
  
  def start(&block)
    @completed = false
    @error = nil
    
    @main = Thread.start do
      @server = HTTPServer.new( :Port => @port )
      @server.mount_proc("/", nil) do |request, response|
        begin
          yield(request, response)
        rescue
          @error = $!
        end
        
        @completed = true
        @monitor.synchronize do
          @cond.signal
        end
      end
      @server.start
    end
  end
  
  def wait
    @monitor.synchronize do
      @cond.wait(WAIT_TIMEOUT)
    end
    raise "HTTP Connection was not completed within #{WAIT_TIMEOUT} seconds" unless @completed
    raise @error if @error
  end
end