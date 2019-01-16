module Todoable
  class Configuration
    attr_accessor :username, :password, :base_url

    DEFAULT_USERNAME = 'hillmandj@gmail.com'
    DEFAULT_PASSWORD = 'todoable'
    DEFAULT_BASE_URL = 'http://todoable.teachable.tech/api/'

    def initialize(
      username: DEFAULT_USERNAME,
      password: DEFAULT_PASSWORD,
      base_url: DEFAULT_BASE_URL
    )
      @username = username
      @password = password
      @base_url = base_url
    end
  end
end
