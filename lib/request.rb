# The Request class encapsulates the parsing of an HTTP Request
module WebServer
  class Request
    attr_accessor :http_method, :uri, :version, :headers, :body, :params
    @socket

    # Request creation receives a reference to the socket over which
    # the client has connected
    def initialize(socket)

      @headers = Hash.new
      @params = Hash.new
      @post_params = Hash.new
      @socket = socket

      # Perform any setup, then parse the request
      parse
    end

    # I've added this as a convenience method, see TODO (This is called from the logger
    # to obtain information during server logging)
    def user_id
      # TODO: This is the userid of the person requesting the document as determined by 
      # HTTP authentication. The same value is typically provided to CGI scripts in the 
      # REMOTE_USER environment variable. If the status code for the request (see below) 
      # is 401, then this value should not be trusted because the user is not yet authenticated.
      '-'
    end

    # Parse the request from the socket - Note that this method takes no
    # parameters
    def parse
      # 1. Get request line
      parse_request_line

      # 2. Get request header
      line = next_line
      until line.chomp!.empty? do 
        parse_header(line)
        line = next_line
      end
      # 3. Get the body
      parse_body
    end

    # The following lines provide a suggestion for implementation - feel free
    # to erase and create your own...
    def next_line
      @socket.gets
    end

    def parse_request_line      
      params = next_line.split(' ')
      @http_method = params[0]
      @uri = params[1][/.*\//]
      @version = params[2]

      # get uri paramas
      if uri_params = params[1][/(?<=\?).*/]
        name,value = uri_params.split('=')
        @params[name] = value
      end
    end

    def parse_header(header_line)
      params = header_line.strip.split(': ')
      @headers[params[0].upcase.gsub('-', '_')] = params[1]
    end

    def parse_body
      return unless (@headers['CONTENT_LENGTH']) && (@headers['CONTENT_LENGTH'].to_i != 0)
      @body = @socket.read(@headers['CONTENT_LENGTH'].to_i)
      if (@http_method == "POST")
        params = @body.split('&')
        params.each do |item|
          name,value = item.split('=')
          @params[name] = value
        end
      end

    end

    def show
      puts "HTTP METHOD:" + @http_method.inspect
      puts "URI:" + @uri.inspect
      puts "VERSION:" + @version.inspect
      puts "HEADERS:" + @headers.inspect
      puts "BODY:" + @body.inspect
      puts "PARAMS:" + @params.inspect
    end
  end
end
