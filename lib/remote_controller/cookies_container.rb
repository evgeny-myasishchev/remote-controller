require 'webrick/cookie'

class RemoteController::CookiesContainer
  def initialize()
    @cookies = {}
  end
  
  def [](name)
    @cookies[name]
  end
  
  def process(set_cookie_string)
    parsed = WEBrick::Cookie.parse_set_cookies(set_cookie_string)
    parsed.each do |cookie|
      @cookies[cookie.name] = cookie
    end
  end
  
  def to_header
    result = ""
    @cookies.each do |name, cookie|
      result << "#{name}=#{cookie.value}; "
    end
    result = result.strip!
    result
  end
  
  def empty?
    @cookies.size == 0
  end
end