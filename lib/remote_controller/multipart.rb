#--
# (c) Copyright 2007-2008 Nick Sieger.
# See the file README.txt included with the distribution for
# software license details.
#++
# (The MIT License)
# 
# Copyright (c) 2007-2009 Nick Sieger <nick@nicksieger.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# 'Software'), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#Example:
# url = URI.parse('http://www.example.com/upload')
# File.open("./image.jpg") do |jpg|
#   req = Net::HTTP::Post::Multipart.new url.path,
#     "file" => UploadIO.new(jpg, "image/jpeg", "image.jpg")
#   res = Net::HTTP.start(url.host, url.port) do |http|
#     http.request(req)
#   end
# end


require 'net/http'
require 'stringio'
require 'cgi'

module RemoteController::Multipart end

require 'remote_controller/multipart/parts'
require 'remote_controller/multipart/composite_io'
require 'remote_controller/multipart/multipartable'

module Net #:nodoc:
  class HTTP #:nodoc:
    class Put
      class Multipart < Put
        include RemoteController::Multipart::Multipartable
      end
    end
    class Post #:nodoc:
      class Multipart < Post
        include RemoteController::Multipart::Multipartable
      end
    end
  end
end