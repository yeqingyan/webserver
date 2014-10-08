module WebServer
  module Response
    # Class to handle 401 responses
    class Unauthorized < Base
      def initialize(resource, options={})
      	super
      end

      def response_header
      	msg = ""
      	msg += f("WWW-Authenticate", "Basic realm=\"TEST\"")
      end
  end


  end
end
