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
  
  def test_callback_invoked
    first_invoked  = false
    second_invoked = false
    @controller.on_error do |error|
      first_invoked = true
    end
    @controller.on_error do |error|
      second_invoked = true
    end
    @context.start do |request, response|
      response.status = 500
    end
    assert_raise(Net::HTTPFatalError) { @controller.just_get }
    @context.wait
    
    assert(first_invoked, "First was not invoked")
    assert(second_invoked, "Second was not invoked")
  end  
  
end
