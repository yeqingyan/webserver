module WebServer
  module Response
    # Class to handle 304 responses
    class NotModified < Base
      def initialize(resource, options={})
      	@code = 304
      	@body = ""
        @modified = File.mtime(resource.resolve).gmtime.strftime("%a, %e %b %Y %H:%M:%S %Z")
      	@version = DEFAULT_HTTP_VERSION
      	@message = ""
      end
    end
  end
end
