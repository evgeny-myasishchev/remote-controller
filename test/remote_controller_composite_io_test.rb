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
require 'stringio'

class RemoteControllerCompositeReadIOTest < Test::Unit::TestCase
  
  include RemoteController::Multipart
  
  def setup
    @io = CompositeReadIO.new(CompositeReadIO.new(StringIO.new('the '), StringIO.new('quick ')),
            StringIO.new('brown '), StringIO.new('fox'))
  end

  def test_full_read_from_several_ios
    assert_equal 'the quick brown fox', @io.read
  end
  
  def test_partial_read
    assert_equal 'the quick', @io.read(9)
  end
  
  def test_partial_read_to_boundary
    assert_equal 'the quick ', @io.read(10)    
  end
  
  def test_read_with_size_larger_than_available
    assert_equal 'the quick brown fox', @io.read(32)
  end
  
  def test_read_into_buffer
    buf = ''
    @io.read(nil, buf)
    assert_equal 'the quick brown fox', buf
  end
  
  def test_multiple_reads
    assert_equal 'the ', @io.read(4)
    assert_equal 'quic', @io.read(4)
    assert_equal 'k br', @io.read(4)
    assert_equal 'own ', @io.read(4)
    assert_equal 'fox',  @io.read(4)
  end
  
  def test_read_after_end
    @io.read
    assert_equal "", @io.read
  end

  def test_read_after_end_with_amount
    @io.read(32)
    assert_equal nil, @io.read(32)
  end
end
