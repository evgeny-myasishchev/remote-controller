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

module RemoteController::Multipart::Multipartable
  DEFAULT_BOUNDARY = "-----------1a5ef2de8917334afe03269e42657dea596c90fb"
  def initialize(path, params, headers={}, boundary = DEFAULT_BOUNDARY)
    super(path, headers)
    parts = params.map {|k,v| RemoteController::Multipart::Parts::Part.new(boundary, k, v)}
    parts << RemoteController::Multipart::Parts::EpiloguePart.new(boundary)
    ios = parts.map{|p| p.to_io }
    self.set_content_type("multipart/form-data", { "boundary" => boundary })
    self.content_length = parts.inject(0) {|sum,i| sum + i.length }
    self.body_stream = RemoteController::Multipart::CompositeReadIO.new(*ios)
  end
end
