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

# Represents a part to be filled from file IO.
class RemoteController::Multipart::Parts::FilePart
  include RemoteController::Multipart::Parts::Part
  attr_reader :length
  def initialize(boundary, name, io)
    file_length = io.respond_to?(:length) ?  io.length : File.size(io.local_path)
    @head = build_head(boundary, name, io.original_filename, io.content_type, file_length)
    @length = @head.length + file_length
    @io = RemoteController::Multipart::CompositeReadIO.new(StringIO.new(@head), io, StringIO.new("\r\n"))
  end

  def build_head(boundary, name, filename, type, content_len)
    part = ''
    part << "--#{boundary}\r\n"
    part << "Content-Disposition: form-data; name=\"#{name.to_s}\"; filename=\"#{filename}\"\r\n"
    part << "Content-Length: #{content_len}\r\n"
    part << "Content-Type: #{type}\r\n"
    part << "Content-Transfer-Encoding: binary\r\n"
    part << "\r\n"
  end
end
