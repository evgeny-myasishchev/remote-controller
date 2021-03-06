require File.expand_path('../lib/remote_controller/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'remote-controller'
  s.version     = RemoteController::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Evgeny Myasishchev']
  s.email       = ['evgeny.myasishchev@gmail.com']
  s.homepage    = 'http://github.com/evgeny-myasishchev/remote-controller'
  s.summary     = %q{Helps to invoke actions of remote controllers.}
  s.description = %q{Library to simplify remote controller actions invocation.}
  
  s.rubyforge_project     = 'remote-controller'
  s.required_ruby_version = '>= 1.9.3'
  
  s.add_dependency 'multipart-post', '>= 1.2.0'

  s.add_development_dependency 'http-testing', '>= 0.1.5'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.require_paths = ['lib']
end
