# The Request class encapsulates the parsing of an HTTP Request
module WebServer
  class Request
    attr_accessor :http_method, :uri, :version, :headers, :body, :params

    # Request creation receives a reference to the socket over which
    # the client has connected
    def initialize(socket)
      @socket = socket
      @headers = Hash.new
      @params = Hash.new
      @body = ""

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
      parse_request_line
      
      line = next_line
      while line != "\n" && line !="\r\n" do
        parse_header(line.tr("\r", ""))
        line = next_line
      end

      parse_body
    end

    # The following lines provide a suggestion for implementation - feel free
    # to erase and create your own...
    def next_line
      @socket.gets
    end

    def parse_request_line
      line = next_line.split(" ")
      @http_method = line[0]
      @uri = line[1]
      if line[1][1] == "?"
        @uri = "/"
        line[1] = line[1].tr("/?", "")
        param = line[1].split("=")
        @params[param[0]] = param[1]
      end
      @version = line[2]
    end

    def parse_header(header_line)
      #p header_line
      if header_line.include? "If-Modified-Since"
        header = header_line.split(": ")
        header[0] = header[0].tr("-", "_")
        @headers[header[0].upcase] = header[1]
        #p @headers[header[0].upcase]
      else
        header = header_line.split(" ")
        header[0] = header[0].tr(":", "")
        header[0] = header[0].tr("-", "_")
      
        header.each do |token|
          @headers[header[0].upcase] = token.tr("\n", "")
        end
      end
    end

    def parse_body
      return unless (@headers["CONTENT_LENGTH"]) && (@headers["CONTENT_LENGTH"].to_i) != 0
      @body = @socket.read(@headers["CONTENT_LENGTH"].to_i)
    end

    def parse_params
    end
  end
end
