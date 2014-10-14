module WebServer
  module Response
    # Class to handle 401 responses
    class Unauthorized < Base
      def initialize(resource, options={})
      	super
        @options = options
      end

      def response_header
      	msg = ""
      	msg += "WWW-Authenticate: %s realm=\"%s\"\n" % [@options['TYPE'], @options['REALM']]
      end
    end
  end
end
