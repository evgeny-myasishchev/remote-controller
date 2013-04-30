require  File.dirname(__FILE__) + '/test_helper'

class RemoteControllerCookiesContainerTest < Test::Unit::TestCase
  
  def setup
    @container = RemoteController::CookiesContainer.new()
  end
  
  def test_process
    cookies_str = "auth_token=tooken; path=/; expires=Thu, 01-Jan-1970 00:00:00 GMT, _session=9999; path=/; HttpOnly"
    @container.process(cookies_str)
    assert_not_nil @container["_session"]
    assert_equal "9999", @container["_session"].value
    
    assert_not_nil @container["auth_token"]
    assert_equal "tooken", @container["auth_token"].value
  end
  
  def test_to_header
    cookies_str = "auth_token=tooken; path=/; expires=Thu, 01-Jan-1970 00:00:00 GMT, _session=9999; path=/; HttpOnly"
    @container.process(cookies_str)
    
    assert_equal @container["_session"].value, '9999'
    assert_equal @container["auth_token"].value, 'tooken'
    # assert_equal "_session=9999; auth_token=tooken;", @container.to_header
  end 
  
  def test_empty?
    assert @container.empty?
    
    cookies_str = "_session=9999;"
    @container.process(cookies_str)
    
    assert !@container.empty?
  end 
end
