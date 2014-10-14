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

    # general headers
    GHEADERS = {
      'Connection' => 'close'
    }

    def self.default_headers
      {
        # Use GMT time for date and expire
        'Date' => Time.now.gmtime.strftime('%a, %e %b %Y %H:%M:%S %Z'),
        'Server' => 'YEQING YAN CSC 867',
        # expire time is 1 day
        'Expires' => (Time.now.gmtime + (24*60*60)).strftime('%a, %e %b %Y %H:%M:%S %Z')

      }
    end

    module Factory
      def self.create(resource, options)
        case resource 
        when 200
          Response::Base.new(resource, options)
        when 201
          Response::SuccessfullyCreated.new(resource, options)
        when 304
          Response::NotModified.new(resource, options)
        when 400
          Response::BadRequest.new(resource, options)
        when 401
          Response::Unauthorized.new(resource, options)
        when 403
          Response::Forbidden.new(resource, options)
        when 404
          Response::NotFound.new(resource, options)
        when 500
          Response::ServerError.new(resource, options)
        end
      end

      def self.error(resource, error_object)
        Response::ServerError.new(resource, exception: error_object)
      end
    end
  end
end
