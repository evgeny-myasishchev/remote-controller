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

# Concatenate together multiple IO objects into a single, composite IO object
# for purposes of reading as a single stream.
#
# Usage:
#
#     crio = CompositeReadIO.new(StringIO.new('one'), StringIO.new('two'), StringIO.new('three'))
#     puts crio.read # => "onetwothree"
#  
class RemoteController::Multipart::CompositeReadIO
  # Create a new composite-read IO from the arguments, all of which should
  # respond to #read in a manner consistent with IO.
  def initialize(*ios)
    @ios = ios.flatten
  end

  # Read from the IO object, overlapping across underlying streams as necessary.
  def read(amount = nil, buf = nil)
    buffer = buf || ''
    done = if amount; nil; else ''; end
    partial_amount = amount

    loop do
      result = done

      while !@ios.empty? && (result = @ios.first.read(partial_amount)) == done
        @ios.shift
      end

      buffer << result if result
      partial_amount -= result.length if partial_amount && result != done

      break if partial_amount && partial_amount <= 0
      break if result == done
    end

    if buffer.length > 0
      buffer
    else
      done
    end
  end
end

# Convenience methods for dealing with files and IO that are to be uploaded.
module RemoteController::Multipart::UploadIO
  # Create an upload IO suitable for including in the params hash of a
  # Net::HTTP::Post::Multipart.
  #
  # Can take two forms. The first accepts a filename and content type, and
  # opens the file for reading (to be closed by finalizer). The second accepts
  # an already-open IO, but also requires a third argument, the filename from
  # which it was opened.
  #
  #     UploadIO.new("file.txt", "text/plain")
  #     UploadIO.new(file_io, "text/plain", "file.txt")
  def self.new(filename_or_io, content_type, filename = nil)
    io = filename_or_io
    unless io.respond_to? :read
      io = File.open(filename_or_io)
      filename = filename_or_io
    end
    convert!(io, content_type, File.basename(filename), filename)
    io
  end

  # Enhance an existing IO for including in the params hash of a
  # Net::HTTP::Post::Multipart by adding #content_type, #original_filename,
  # and #local_path methods to the object's singleton class.
  def self.convert!(io, content_type, original_filename, local_path)
    io.instance_eval(<<-EOS, __FILE__, __LINE__)
      def content_type
        "#{content_type}"
      end
      def original_filename
        "#{original_filename}"
      end
      def local_path
        "#{local_path}"
      end
    EOS
    io
  end
end
