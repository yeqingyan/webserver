module WebServer
  module Response
    # Class to handle 404 errors
    class NotFound < Base
      def initialize(resource, options={})
        @request = resource
        @code = 404
        @body = @code.to_s + " " + RESPONSE_CODES[@code]
      end
    end
  end
end
