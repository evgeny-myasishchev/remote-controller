module RemoteController 
  require 'remote_controller/multipart'
  autoload :CookiesContainer, 'remote_controller/cookies_container'
  autoload :CGIHelpers, 'remote_controller/cgi_helpers'
  autoload :Base, 'remote_controller/base'
  
  def self.file_part(file_path, content_type)
    RemoteController::Multipart::UploadIO.new(file_path, content_type)
  end
end