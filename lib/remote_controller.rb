module RemoteController 
  def self.file_part(file_path, content_type)
    RemoteController::Multipart::UploadIO.new(file_path, content_type)
  end
end

require 'remote_controller/multipart'
require 'remote_controller/cookies_container'  
require 'remote_controller/base'
  