module WebServer
  module Response
    # Provides the base functionality for all HTTP Responses 
    # (This allows us to inherit basic functionality in derived responses
    # to handle response code specific behavior)

    # By YEQING YAN 
    # Base is 200
    class Base
      attr_reader :version, :code, :body, :request, :age, :mtime, :type

      def initialize(resource, options={})
        if options['BODY']
          @body = options['BODY']
        else
          @body = ''
        end

        if options['AGE']
          @age = options['AGE']
        end

        if options['LAST_MODIFIED']
          @mtime = options['LAST_MODIFIED']
        end

        if options['TYPE']
          @type = options['TYPE'].split('.')[1]
        end

        @code = resource

      end

      def to_s
        msg = header
        msg += @body+"\n"
      end

      # Generate header
      def header
        msg = ""
        msg += status_line(@code) + "\n"
        msg += entity_header
        msg += general_header
        msg += response_header
        msg += "\n" 
        return msg
      end

      def message

      end

      def content_length
      end

      # <status-line>
      # <general-headers>
      # <response-headers>
      # <entity-headers>
      # <empty-line>
      def status_line(code)
        return DEFAULT_HTTP_VERSION + " " + code.to_s + " " + RESPONSE_CODES[code]
      end

      def general_header
        msg = ""
        msg += f("Connection", GHEADERS["Connection"])
        msg += f('Date', Response::default_headers['Date'])
        msg += f('Server', Response::default_headers['Server']) 
        msg += f('Expires', Response::default_headers['Expires']) 
        #msg += f('Age', @age) unless @age.nil?
        msg += f('Last-Modified', @mtime) unless @mtime.nil?
        return msg
      end

      # 
      def response_header
        return ""
      end

      def entity_header
        msg = ""
        if @type.nil?         
          msg += f("Content-Type", $mime_conf.for_extension('random'))
        else
          msg += f("Content-Type", $mime_conf.for_extension(@type))
        end
        
        if @body.empty?
          msg += f("Content-Length", 0)
        else
          msg += f("Content-Length", @body.bytesize)
        end
        return msg
      end

      def f(string1, string2)
        "%s: %s\n" % [string1, string2]
      end

    end
  end
end
