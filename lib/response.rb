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
        @code = 200
        @response = ""

        case resource.request.http_method
        when "GET"
          get_resource(resource)
        when "HEAD"
          return "HEAD"
        when "POST"
          return "POST"
        when "PUT"
          return "PUT"
        else
          return Response::BadRequest.new(resource, options)
        end
        
        options = Hash.new
        options['CODE'] = @code

        case @code
        when 200
          options['BODY'] = resource.resolve
          Response::Base.new(resource, options)
        when 201
          Response::SuccessfullyCreated.new(resource, options)
        when 304
          Response::NotModified.new(resource, options)
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

      def self.get_resource(resource)
        if resource.protected? && resource.request.headers['AUTHORIZATION'] == nil
          @code = 401
        elsif resource.protected? && resource.request.headers['AUTHORIZATION'] == false
          @code = 403
        end

        path = resource.resolve
        @code = 404 unless File.exists?(path)

        #304 simple caching
        if resource.request.headers["IF_MODIFIED_SINCE"]
          time = resource.request.headers["IF_MODIFIED_SINCE"].tr("\n", "")
          if time == File.mtime(resource.resolve).gmtime.strftime("%a, %e %b %Y %H:%M:%S %Z")
            @code = 304
          end
        end
      end
    end
  end
end
