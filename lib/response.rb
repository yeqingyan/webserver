require_relative 'response/base'

module WebServer
  module Response
    DEFAULT_HTTP_VERSION = 'HTTP/1.1'

    RESPONSE_CODES = {
      200 => 'OK',
      201 => 'Successfully Created',
      304 => 'Not Modified',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      500 => 'Internal Server Error'
    }

    def self.default_headers
      {
        'Date' => Time.now.strftime('%a, %e %b %Y %H:%M:%S %Z'),
        'Server' => 'Jacob Gronert CSC 667'
      }
    end

    module Factory
      def self.create(resource, options)
        case resource
        when 200
          Response::Base.new(resource, options)
        end
      end

      def self.error(resource, error_object)
        Response::ServerError.new(resource, exception: error_object)
      end
    end
  end
end
