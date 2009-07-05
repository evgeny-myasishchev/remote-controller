require 'net/http'

class RemoteController::Base
  
  class RemoteControllerError < StandardError #:nodoc:
  end
  
  def initialize(url)
    @url = url
  end
  
  def cookies_container
    @cookies_container = @cookies_container || RemoteController::CookiesContainer.new
  end
  
  def cookies_container=(container)
    @cookies_container = container
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
    if args.length > 1 || (args.length == 1 && !args[0].is_a?(Hash))
      raise RemoteControllerError.new("Invalid arguments.")
    elsif args.length == 1
      parameters = args.shift
    end
    
    #Now we can send the request
    send_request(action_name, method, parameters)
  end
  
  private
    def send_request(action_name, method, parameters)
      
      uri = URI.parse(@url)
      action_path = "#{uri.path}/#{action_name}"
      
      request = nil
      
      case method
      when :get
        request = Net::HTTP::Get.new("#{action_path}?#{parameters.to_param}")
      when :post
        request = Net::HTTP::Post.new(action_path)
        request.body = parameters.to_param
      when :multipart
        request = Net::HTTP::Post::Multipart.new(action_path, parameters)
      else
        raise RemoteControllerError.new("Unsupported method")
      end
      initialize_request(request)
      response = Net::HTTP.start(uri.host, uri.port) {|http|
            http.request(request)
      }
      process_headers(response)
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