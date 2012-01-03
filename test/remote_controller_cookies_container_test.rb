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
