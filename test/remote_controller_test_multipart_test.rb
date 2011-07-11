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

require  File.dirname(__FILE__) + '/test_helper'

class RemoteControllerMultiPartTest < Test::Unit::TestCase
  
  include RemoteController::Multipart
  
  TEMP_FILE = "temp.txt"

  HTTPPost = Struct.new("HTTPPost", :content_length, :body_stream, :content_type)
  HTTPPost.module_eval do
    def set_content_type(type, params = {})
      self.content_type = type + params.map{|k,v|"; #{k}=#{v}"}.join('')
    end
  end
  
  def setup
    @another_temp_file = "#{File.dirname(__FILE__)}/../tmp/temp_file.txt"
  end

  def teardown
    File.delete(TEMP_FILE) rescue nil
    File.delete(@another_temp_file) rescue nil
  end

  def test_form_multipart_body
    File.open(TEMP_FILE, "w") {|f| f << "1234567890"}
    @io = File.open(TEMP_FILE)
    UploadIO.convert! @io, "text/plain", TEMP_FILE, TEMP_FILE
    assert_results Net::HTTP::Post::Multipart.new("/foo/bar", :foo => 'bar', :file => @io)
  end
  def test_form_multipart_body_no_text_plain
    File.open(@another_temp_file, "w") {|f| f << "1234567890"}
    @io = File.open(@another_temp_file)
    UploadIO.convert! @io, "application/octet-stream", File.basename(@another_temp_file), File.basename(@another_temp_file)    
    file_part = RemoteController::Multipart::Parts::FilePart.new("--bound", "name", @io)
  end  
  def test_form_multipart_body_put
    File.open(TEMP_FILE, "w") {|f| f << "1234567890"}
    @io = File.open(TEMP_FILE)
    UploadIO.convert! @io, "text/plain", TEMP_FILE, TEMP_FILE
    assert_results Net::HTTP::Put::Multipart.new("/foo/bar", :foo => 'bar', :file => @io)
  end
  
  def test_form_multipart_body_with_stringio
    @io = StringIO.new("1234567890")
    UploadIO.convert! @io, "text/plain", TEMP_FILE, TEMP_FILE
    assert_results Net::HTTP::Post::Multipart.new("/foo/bar", :foo => 'bar', :file => @io)
  end

  def assert_results(post)
    assert post.content_length && post.content_length > 0
    assert post.body_stream
    assert_equal "multipart/form-data; boundary=#{Multipartable::DEFAULT_BOUNDARY}", post['content-type']
    body = post.body_stream.read
    boundary_regex = Regexp.quote Multipartable::DEFAULT_BOUNDARY
    assert body =~ /1234567890/
    # ensure there is at least one boundary
    assert body =~ /^--#{boundary_regex}\r\n/
    # ensure there is an epilogue
    assert body =~ /^--#{boundary_regex}--\r\n/
    assert body =~ /text\/plain/
  end
end
