require  File.dirname(__FILE__) + '/test_helper'

class RemoteControllerTest < Test::Unit::TestCase
  
  BASE_SERVER_PORT = 4982
  
  def setup
    @server_port = BASE_SERVER_PORT + rand(100)
    @context = RemoteController::Testing::HttpContext.new(@server_port)
    @controller = RemoteController::Base.new("http://localhost:#{@server_port}/test_controller")
  end
  
  # def test_integration
  #   sessions = RemoteController::Base.new("http://localhost:3000/integration/sessions")
  #   authenticity_token = sessions.new
  #   sessions.create(:login => "admin", :password => "password")
  #   
  #   layouts = RemoteController::Base.new("http://localhost:3000/integration/layouts")
  #   layouts.cookies_container = sessions.cookies_container
  #   puts layouts.index
  #   
  #   resources = RemoteController::Base.new("http://localhost:3000/integration/resources")
  #   resources.cookies_container = sessions.cookies_container
  #   
  #   puts "-----------files before------------"
  #   resources.index
  #   
  #   # Adding new files
  #   puts resources.create(:multipart, {
  #     :authenticity_token => authenticity_token,
  #     "record[path]" => "/images",
  #     "record[name]" => RemoteController.file_part("/Users/jenya/projects/xtms-app/public/favicon.ico", "image/jpeg")
  #   })
  #   
  #   puts "-----------files after------------"
  #   puts resources.index
  # end
  
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
  
  def test_invoke_string_post
    @context.start do |request, response|
      assert_equal "POST", request.request_method
      assert_equal "string post", request.body
    end
    @controller.args_post(:post, "string post")
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
  
  def test_cookies_container
    @context.start do |request, response|
      response["set-cookie"] = "_session=9999; path=/; HttpOnly"
    end
    @controller.action
    @context.wait
    
    assert_equal "9999", @controller.cookies_container["_session"].value
    
    container = @controller.cookies_container
    
    @controller = RemoteController::Base.new("http://localhost:#{@server_port}/test_controller")
    @controller.cookies_container = container
    @context.start do |request, response|
      assert_equal 1, request.cookies.length
      assert_equal "_session=9999;", request.cookies[0].to_s
    end
    @controller.action
    @context.wait
  end
end