module WebServer
  module Response
    # Class to handle 403 responses
    class Forbidden < Base
      def initialize(resource, options={})
        @request = resource
      	@code = 403
      	@body = @code.to_s + " " + RESPONSE_CODES[@code]
      end
    end
  end
end
