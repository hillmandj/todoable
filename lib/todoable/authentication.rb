# frozen_string_literal: true

module Todoable
  class Authentication
    attr_reader :username, :password, :base_url, :response, :token

    def initialize(username:, password:, base_url:)
      @username = username
      @password = password
      @base_url = base_url
    end

    def fetch_token
      @response = JSON.parse(client.post.body)
      @token = @response['token']
    rescue => e
      raise AuthenticationError.new("Invalid Credentials", 404)
    end

    private

    def client
      @client ||= Faraday.new(auth_url) do |conn|
        conn.adapter Faraday.default_adapter
        conn.basic_auth(username, password)
      end
    end

    def auth_url
      base_url + 'authenticate'
    end

    def headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
      }
    end
  end
end
