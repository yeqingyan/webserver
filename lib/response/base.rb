module WebServer
  module Response
    # Provides the base functionality for all HTTP Responses 
    # (This allows us to inherit basic functionality in derived responses
    # to handle response code specific behavior)
    class Base
      attr_reader :version, :code, :body

      def initialize(resource, options={})
        @code = options['CODE']
        @version = DEFAULT_HTTP_VERSION
        
        if options['BODY']
          path = options['BODY']
          @body = File.open(path, 'r').read
        end

        if resource.script_aliased?
          @body = IO.popen(path).read
        end

        @messsage = ""
      end

      def to_s
        # method in charge of constructing @message

        #Status Line
        @message = @version + " " + @code.to_s + " " +RESPONSE_CODES[@code]+ "\n"

        #General Headers
        @message += "Date: " + Response.default_headers["Date"] + "\n"
        
        #Response Headers
        @message += "Server: " + Response.default_headers["Server"] + "\n"

        #Entity Headers

        #New line to signify start of body
        @message += "\n"
        #p @message + "--- BODY HERE -----\n ----- END RESPONSE ---"

        #Message Body
        @message += @body
      end


    end
  end
end
