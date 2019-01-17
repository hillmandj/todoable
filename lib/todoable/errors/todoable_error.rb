module Todoable
  class TodoableError < StandardError
    attr_reader :status, :message, :body

    def initialize(message = nil, status = nil, body = {})
      @status  = status
      @message = message
      @body    = body
    end

    def to_s
      status_string = "Status: #{status}," if status
      body_string = ", Body: #{body.to_s}" unless body.empty?
      "#{status_string} Message: #{message}#{body_string}"
    end
  end
end
