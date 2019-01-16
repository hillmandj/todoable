module Todoable
  class TodoableError < StandardError
    attr_reader :status, :message, :body

    def initialize(message = nil, status = nil, body = {})
      @status  = status
      @message = message
      @body    = body
    end

    def to_s
      status_string = "Status: #{status},"
      "#{status_string if status} Message: #{message}"
    end
  end
end
