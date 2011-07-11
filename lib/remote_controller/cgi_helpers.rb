module RemoteController::CGIHelpers
  require 'cgi'
  
  def to_param(object)
    return CGI.escape(object.to_s) unless object.is_a? Hash
    object.collect do |key, value|
      "#{CGI.escape(key.to_s).gsub(/%(5B|5D)/n) { [$1].pack('H*') }}=#{CGI.escape(value.to_s)}"
    end.sort * '&'
  end  
end