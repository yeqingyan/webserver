module WebServer
  module Response
    # Class to handle 400 responses
    class BadRequest < Base
      def initialize(resource, options={})
        @request = resource
        @code = 400
        @body = @code.to_s + " " + RESPONSE_CODES[@code]
      end
    end
  end
end
