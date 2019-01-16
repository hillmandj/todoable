$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'todoable/version'

Gem::Specification.new do |s|
  # Basic information
  s.name         = 'todoable'
  s.summary      = 'Ruby bindings for todoable API'
  s.description  = 'Todoable is an application to retrieve and create todos!'
  s.authors      = ['Daniel Hillman']
  s.email        = ['hillmandj@gmail.com']
  s.version      = Todoable::VERSION
  s.homepage     = 'http://github.com/hillmandj/todoable'

  # Files & paths
  s.files        = Dir['lib/**/*', 'LICENSE', 'README.md', 'CHANGELOG.md']
  s.test_files   = Dir['spec/**/*']
  s.require_path = ['lib']

  # Ruby version
  s.required_ruby_version = '>= 2.0'

  # Dependencies
  s.add_dependency 'faraday', '~> 0.15'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'pry'
end