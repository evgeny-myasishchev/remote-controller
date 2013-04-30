module RemoteController 
  class DefaultLogFactory
    def self.create_logger(name)
      require 'logger' unless defined? Logger
      log = Logger.new(STDOUT)
      log.formatter = proc do |severity, datetime, progname, msg|
        "#{datetime.strftime('%Y-%m-%d %H:%M:%S,%L')} [#{severity}] (#{name}) - #{msg}\n"
      end
      log
    end
  end
  
  class EmptyLoggerFactory
    def self.fatal(*args); end
    def self.error(*args); end
    def self.warn(*args); end
    def self.info(*args); end
    def self.debug(*args); end
    
    def self.create_logger(*args)
      self
    end
  end
  
  require 'net/http/post/multipart'
  autoload :CookiesContainer, 'remote_controller/cookies_container'
  autoload :CGIHelpers, 'remote_controller/cgi_helpers'
  autoload :Base, 'remote_controller/base'
  autoload :VERSION, 'remote_controller/version'
  
  def self.file_part(file_path, content_type)
    UploadIO.new(file_path, content_type)
  end
end