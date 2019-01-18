# frozen_string_literal: true

module Todoable
  class ResponseMiddleware < Faraday::Response::Middleware
    def call(env)
      response = @app.call(env)
      body = JSON.parse(env[:body]) rescue {} # rescuing in case of empty body

      case response.status
      when 400
        raise InvalidRequestError.new("Bad Request", 400, body)
      when 401
        @app.call(set_new_token(env)) # Retry if token expired
      when 404
        raise NotFoundError.new("Resource Not Found", 404, body)
      when 422
        raise UnprocessableError.new("Unprocessable Entity", 422, body)
      else
        response
      end
    end

    private

    def set_new_token(env)
      new_token = Todoable.authentication.fetch_token
      auth_header = Todoable.client.token_auth(new_token)
      env.request_headers['Authorization'] = auth_header
      env
    end
  end
end
