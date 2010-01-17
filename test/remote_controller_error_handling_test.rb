require  File.dirname(__FILE__) + '/test_helper'

class RemoteControllerErrorHandlingTest < Test::Unit::TestCase
  BASE_SERVER_PORT = 5982
  
  def setup
    @server_port = BASE_SERVER_PORT + rand(100)
    @context     = RemoteController::Testing::HttpContext.new(@server_port)
    @controller  = RemoteController::Base.new("http://localhost:#{@server_port}/test_controller")
  end
  
  def test_exception_raised
    @context.start do |request, response|
      response.status = 500
    end
    assert_raise(Net::HTTPFatalError) { @controller.just_get }
    @context.wait
  end
  
  # def test_exception_raised
  #   @context.start do |request, response|
  #     response.status = 500
  #   end
  #   begin
  #     @controller.just_get
  #   rescue
  #     puts $!.response
  #   end
  #   @context.wait
  # end
  
end
