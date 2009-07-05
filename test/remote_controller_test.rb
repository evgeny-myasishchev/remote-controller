require  File.dirname(__FILE__) + '/test_helper'

class RemoteControllerTest < Test::Unit::TestCase
  
  BASE_SERVER_PORT = 4982
  
  def setup
    @server_port = BASE_SERVER_PORT + rand(100)
    @context = RemoteController::Testing::HttpContext.new(@server_port)
    @controller = RemoteController::Base.new("http://localhost:#{@server_port}/test_controller")
  end
  
  def test_invoke_no_args_get
    @context.start do |request, response|
      assert_equal "GET", request.request_method
      assert_equal "/test_controller/no_args_get", request.path
    end
    @controller.no_args_get
    @context.wait
  end
  
  def test_invoke_args_get
    @context.start do |request, response|
      assert_equal "GET", request.request_method
      assert_equal "/test_controller/args_get?arg1=value1&arg2=value2", request.path + "?" + request.query_string
    end
    @controller.args_get(:arg1 => "value1", :arg2 => "value2")
    @context.wait
  end  
  
  def test_invoke_no_args_post
    @context.start do |request, response|
      assert_equal "POST", request.request_method
      assert_equal "/test_controller/no_args_post", request.path
    end
    @controller.no_args_post(:post)
    @context.wait
  end  
  
  def test_invoke_args_post
    @context.start do |request, response|
      assert_equal "POST", request.request_method
      assert_equal ({:arg1 => "value1", :arg2 => "value2"}.to_param), request.body
    end
    @controller.args_post(:post, {:arg1 => "value1", :arg2 => "value2"})
    @context.wait
  end
  
  def test_invoke_args_multipart
    @context.start do |request, response|
      assert_equal "POST", request.request_method
      assert_equal ["multipart/form-data; boundary=#{Net::HTTP::Post::Multipart::DEFAULT_BOUNDARY}"], request.header["content-type"]
    end
    @controller.args_post(:multipart, {:arg1 => "value1", :arg2 => "value2"})
    @context.wait
  end  
  
end
