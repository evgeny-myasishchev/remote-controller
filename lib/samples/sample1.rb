ENV['BUNDLE_GEMFILE'] = File.expand_path('../../../Gemfile', __FILE__)
require 'rubygems'
require 'bundler/setup'
require 'http-testing'
require 'remote-controller'

address = "http://localhost:30013"
context = HttpTesting::Context.start(30013) do |request, response|
  puts "#{request.request_method} #{address}#{request.path}"
  puts request.body if request.body
  puts ""

  if request.path == "/sessions/authenticity_token"
    response.body = "authenticity token"
  end
end

#Reusable cookies container to persist cookies between different remote controllers of the same remote application
cookies_container = RemoteController::CookiesContainer.new

#Sessions controller is bound to 'http://localhost:300013/sessions' url
sessions                   = RemoteController::Base.new(URI::join(address, "/sessions").to_s)
sessions.cookies_container = cookies_container

# GET: http://localhost:300013/sessions/authenticity_token
# Response is string containing authenticity token. It will also start a new session. 
# CookiesContainer will hold session cookies (and all other cookies) automatically
authenticity_token = sessions.authenticity_token

# POST http://localhost:300013/sessions/authorize
# POST body: 
# => authenticity_token=authenticity+token&login=admin&password=password
# => in case response is not 200 then exception is thrown
sessions.authorize(:post, :authenticity_token => authenticity_token, :login => "admin", :password => "password")

#Reports controller is bound to: http://localhost:300013/reports
reports                    = RemoteController::Base.new(URI::join(address, "/reports").to_s)
sessions.cookies_container = cookies_container #Reusing cookies container to preserve the same session...

# POST http://localhost:300013/sessions/create
# POST body is in multipart post form. It has two parts: 
# => name = New report
# => attachment = sample1.txt file
attachment = RemoteController.file_part(File.expand_path("../sample1.txt", __FILE__), "text/plain")
reports.create(:multipart, :name => "New report", :attachment => attachment)

context.wait
