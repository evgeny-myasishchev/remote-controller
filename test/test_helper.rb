require 'rubygems'

ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup'

require 'test/unit'
require 'cgi'
require 'http-testing'
require 'remote_controller'

class Test::Unit::TestCase
  include RemoteController::CGIHelpers
end