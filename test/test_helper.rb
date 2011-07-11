require 'test/unit'

$:.unshift File.dirname(__FILE__) + '/../lib/remote_controller'

require File.dirname(__FILE__) + '/../init'

require 'cgi'
require 'testing'

class Test::Unit::TestCase
  include RemoteController::CGIHelpers
end