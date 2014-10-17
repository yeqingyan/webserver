module WebServer
  module Response
    # Class to handle 404 errors
    class NotFound < Base
      def initialize(resource, options={})
      	@code = options['CODE']
      	@body = options['CODE'].to_s + " " + RESPONSE_CODES[@code] + "\n"
      	@version = DEFAULT_HTTP_VERSION
      	@message = ""
      end
    end
  end
end
