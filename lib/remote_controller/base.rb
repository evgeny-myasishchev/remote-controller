require 'net/http'

class RemoteController::Base
  DefaultMultipartBoundary = "-----------1a5ef2de8917334afe03269e42657dea596c90fb"
  
  include RemoteController::CGIHelpers
  
  class RemoteControllerError < StandardError #:nodoc:
  end
  
  def initialize(url, options = {})
    @options = {
      verbose: false,
      log_factory: RemoteController::DefaultLogFactory
    }.merge options
    
    logger_factory = @options[:verbose] ? @options[:log_factory] : RemoteController::EmptyLoggerFactory
    @log = logger_factory.create_logger('remote-controller')
    
    @url = url
    @error_handlers = []
  end
  
  def cookies_container
    @cookies_container = @cookies_container || RemoteController::CookiesContainer.new
  end
  
  def cookies_container=(container)
    @cookies_container = container
  end
  
  def on_error(&block)
    raise "No block given" unless block_given?
    @error_handlers << block
  end
  
  def method_missing(symbol, *args)
    
    #Following stuff is required to send requests to remote controllers
    action_name = symbol.to_s
    method = :get
    parameters = {}
    
    #Processing arguments
    if args.length > 0
      method = args.shift if([:get, :post, :multipart].include?(args[0]))
    end
    if args.length > 1
      raise RemoteControllerError.new("Invalid arguments.")
    elsif args.length == 1  && (args[0].is_a?(Hash) || args[0].is_a?(String))
      parameters = args.shift
    end
    
    #Now we can send the request
    send_request(action_name, method, parameters)
  end
  
  private
    def send_request(action_name, method, parameters)
      
      uri = URI.parse(@url)
      action_path = "#{uri.path}/#{action_name}"
      @log.info('Preparing request...')
      request = nil
      case method
      when :get
        request = Net::HTTP::Get.new("#{action_path}?#{to_param(parameters)}")
      when :post
        request = Net::HTTP::Post.new(action_path)
        request.body = to_param(parameters)
      when :multipart
        request = Net::HTTP::Post::Multipart.new(action_path, parameters, {}, DefaultMultipartBoundary)
      else
        raise RemoteControllerError.new("Unsupported method")
      end
      initialize_request(request)
      @log.info("Sending request. Method: #{method}, uri: #{action_path}.")
      response = Net::HTTP.start(uri.host, uri.port) {|http|
            http.request(request)
      }
      @log.info("Response received: #{response.code} #{response.message}")
      process_headers(response)
      begin
        @log.info('Evaluating response')
        response.value #Will raise error in case response is not 2xx
      rescue
        @log.info("Response returned error: #{$!}")
        @error_handlers.each { |e| e.call($!) }
        raise $!
      end
      response.body
    end
    
    def initialize_request(request)
      request["cookie"] = cookies_container.to_header unless cookies_container.empty?
    end
    
    def process_headers(response)
      cookies = response["set-cookie"]
      if(cookies)
        cookies_container.process(cookies)
      end
    end
end