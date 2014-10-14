module WebServer
  module Response
    # Class to handle 304 responses
    class NotModified < Base
      def initialize(resource, options={})
      	@request = resource
      	@code = 304
      	@body = ""
      end
    end
  end
end
