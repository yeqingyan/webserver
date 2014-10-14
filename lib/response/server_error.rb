module WebServer
  module Response
    # Class to handle 500 errors
    class ServerError < Base
      def initialize(resource, options={})
        @request = resource
        @code = 500
        @body = @code.to_s + " " + RESPONSE_CODES[@code]
      end
    end
  end
end
