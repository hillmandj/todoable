require 'json'
require 'faraday'

# Version
require 'todoable/version'

# Services
require 'todoable/configuration'
require 'todoable/authentication'
require 'todoable/response_middleware'

# Error Objects
require 'todoable/errors/todoable_error'
require 'todoable/errors/not_found_error'
require 'todoable/errors/unprocessable_error'
require 'todoable/errors/authentication_error'
require 'todoable/errors/invalid_request_error'

# Resources
require 'todoable/resource'
require 'todoable/list'
require 'todoable/item'

module Todoable
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
    configuration
  end

  def self.authentication
    @authentication ||= Authentication.new(
      username: configuration.username,
      password: configuration.password,
      base_url: configuration.base_url,
    )
  end

  def self.client
    @client ||= Faraday.new(configuration.base_url) do |c|
      c.use Todoable::ResponseMiddleware
      c.token_auth(authentication.token)
      c.adapter Faraday.default_adapter
    end
  end
end
