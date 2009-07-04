require 'net/http'

class RemoteController::Base
  
  class RemoteControllerError < StandardError #:nodoc:
  end
  
  def initialize(url)
    @url = url
  end
  
  def method_missing(symbol, *args)
    
    #Following stuff is required to send requests to remote controllers
    action_name = symbol.to_s
    method = :get
    parameters = {}
    
    #Processing arguments
    if args.length > 0
      method = args.shift if([:get, :post].include?(args[0]))
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
      else
        raise RemoteControllerError.new("Unsupported method")
      end
      
      response = Net::HTTP.start(uri.host, uri.port) {|http|
            http.request(request)
      }
      response.body  
    end
end