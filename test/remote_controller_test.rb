require  File.dirname(__FILE__) + '/test_helper'

class RemoteControllerTest < ActiveSupport::TestCase
  
  SERVER_PORT = 4982
  
  def setup
    @context = RemoteController::Testing::HttpContext.new(SERVER_PORT)
  end
  
  def test_arguments_parsing
    controller = RemoteController::Base.new("http://localhost:#{SERVER_PORT}/test_controller")
    instance = self
    
    controller.class.send(:define_method, :send_request) do |action_name, method, parameters|
      instance.assert_equal "no_args_get", action_name
      instance.assert_equal :get, method
      instance.assert_equal 0, parameters.size
    end
    controller.no_args_get
    
    controller.class.send(:define_method, :send_request) do |action_name, method, parameters|
      instance.assert_equal "no_args_post", action_name
      instance.assert_equal :post, method
      instance.assert_equal 0, parameters.size
    end
    controller.no_args_post(:post)

    controller.class.send(:define_method, :send_request) do |action_name, method, parameters|
      instance.assert_equal "post_with_args", action_name
      instance.assert_equal :post, method
      instance.assert_equal({:id => 10}, parameters)
    end
    controller.post_with_args(:post, {:id => 10})
    
    controller.class.send(:define_method, :send_request) do |action_name, method, parameters|
      instance.assert_equal "get_with_args", action_name
      instance.assert_equal :get, method
      instance.assert_equal({:id => 10}, parameters)
    end
    #Default method is get
    controller.get_with_args({:id => 10})    
    
    assert_raise RemoteController::Base::RemoteControllerError do
      controller.invalid_args_action("invalid arg")
    end
    
    assert_raise RemoteController::Base::RemoteControllerError do
      controller.invalid_args_action(:get, "invalid arg")
    end
  end
  
end
