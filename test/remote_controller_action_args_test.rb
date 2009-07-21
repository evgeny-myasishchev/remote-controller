require  File.dirname(__FILE__) + '/test_helper'

class RemoteControllerActionArgsTest < Test::Unit::TestCase
  
  def setup
    @controller = RemoteController::Base.new("http://localhost:#{@server_port}/test_controller")
    
    #Preserving send_request method. We'll need to restore it later
    @origin_method = @controller.method(:send_request)
  end
  
  def teardown
    #Restoring original method. Required to make subsequent tests work
    @controller.class.send(:define_method, :send_request, @origin_method)
  end

  #The test have to be in a separate class because it changes :send_requrest method
  def test_arguments_parsing
    instance = self
    
    @controller.class.send(:define_method, :send_request) do |action_name, method, parameters|
      instance.assert_equal "no_args_get", action_name
      instance.assert_equal :get, method
      instance.assert_equal 0, parameters.size
    end
    @controller.no_args_get
    
    @controller.class.send(:define_method, :send_request) do |action_name, method, parameters|
      instance.assert_equal "no_args_post", action_name
      instance.assert_equal :post, method
      instance.assert_equal 0, parameters.size
    end
    @controller.no_args_post(:post)

    @controller.class.send(:define_method, :send_request) do |action_name, method, parameters|
      instance.assert_equal "post_with_args", action_name
      instance.assert_equal :post, method
      instance.assert_equal({:id => 10}, parameters)
    end
    @controller.post_with_args(:post, {:id => 10})
    
    @controller.class.send(:define_method, :send_request) do |action_name, method, parameters|
      instance.assert_equal "post_raw_string", action_name
      instance.assert_equal :post, method
      instance.assert_equal("raw_string_data", parameters)
    end
    @controller.post_raw_string(:post, "raw_string_data")
    
    @controller.class.send(:define_method, :send_request) do |action_name, method, parameters|
      instance.assert_equal "multipart_with_args", action_name
      instance.assert_equal :multipart, method
      instance.assert_equal({:id => 10}, parameters)
    end
    @controller.multipart_with_args(:multipart, {:id => 10})    
    
    @controller.class.send(:define_method, :send_request) do |action_name, method, parameters|
      instance.assert_equal "get_with_args", action_name
      instance.assert_equal :get, method
      instance.assert_equal({:id => 10}, parameters)
    end
    #Default method is get
    @controller.get_with_args({:id => 10})
    
    assert_raise RemoteController::Base::RemoteControllerError do
      @controller.invalid_args_action("invalid arg", "invalid arg again")
    end
    
    assert_raise RemoteController::Base::RemoteControllerError do
      @controller.invalid_args_action(:get, "invalid arg", "invalid arg again")
    end
  end  
end
