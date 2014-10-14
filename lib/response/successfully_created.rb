module WebServer
  module Response
    # Class to handle 201 responses
    class SuccessfullyCreated < Base
      def initialize(resource, options={})
      	@request = resource
      	@code = 201
      	@body = @code.to_s + " " + RESPONSE_CODES[@code]
      end
    end
  end
end
