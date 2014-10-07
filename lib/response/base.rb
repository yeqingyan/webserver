module WebServer
  module Response
    # Provides the base functionality for all HTTP Responses 
    # (This allows us to inherit basic functionality in derived responses
    # to handle response code specific behavior)

    # By YEQING YAN 
    # Base is 200
    class Base
      attr_reader :version, :code, :body, :request

      def initialize(resource, options={})
        @request = resource
        
        #if request.http_method == "GET"
        #  get_uri(request.uri)
        #else 
        #  @body = ""
        #end
        if options["BODY"]
          @body = options["BODY"]
        else
          @body = ""
        end

        @code = 200
      end

      def to_s
        
      end

      def message
        msg = ""
        msg += status_line(@code) + "\n"
        msg += entity_header
        msg += general_header
        msg += "\n" 
        msg += @body+"\n"
      end

      def content_length
      end

      # <status-line>
      # <general-headers>
      # <response-headers>
      # <entity-headers>
      # <empty-line>
      def status_line(code)
        puts DEFAULT_HTTP_VERSION.inspect
        puts RESPONSE_CODES[code]
        return DEFAULT_HTTP_VERSION + " " + code.to_s + " " + RESPONSE_CODES[code]
      end

      def general_header
        msg = ""
        msg += f("Connection", GHEADERS["Connection"])
        msg += f('Date', Response::default_headers['Date'])
        msg += f('Server', Response::default_headers['Server']) 
        msg
      end

      def response_header
      end

      def entity_header
        msg = ""
        msg += f("Content-Type", CTYPE["DEFAULT"])
        msg += f("Content-Length", @body.bytesize) unless @body.empty?
        msg
      end

      def f(string1, string2)
        "%s: %s\n" % [string1, string2]
      end

    end
  end
end
