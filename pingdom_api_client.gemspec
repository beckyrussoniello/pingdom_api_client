$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pingdom_api_client/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pingdom_api_client"
  s.version     = PingdomApiClient::VERSION
  s.authors     = ["Becky Russoniello"]
  s.email       = ["becky.russoniello@gmail.com"]
  s.homepage    = "http://beckyrussoniello.github.com"
  s.summary     = "Ruby wrapper for the Pingdom REST API"
	s.license			= "MIT"
  s.description = "Create, modify, and delete checks with the Pingdom REST API."

  s.files = Dir["{lib}/**/*"] #+ ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "httparty"
  s.add_dependency "google-adwords-api"

  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'timecop'
	s.add_development_dependency 'webmock'
end
