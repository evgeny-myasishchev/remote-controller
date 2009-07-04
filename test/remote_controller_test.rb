require  File.dirname(__FILE__) + '/test_helper'

class RemoteControllerTest < ActiveSupport::TestCase
  
  def setup
    @context = RemoteController::Testing::HttpContext.new(3000)
  end
  
  def test_something
    @context.start do |request, response|
      puts request
      puts response
    end
    @context.wait
  end
  
end
