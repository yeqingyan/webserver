require 'socket'
Dir.glob('lib/**/*.rb').each do |file|
  require file
end

module WebServer
  class Server
    attr_accessor :httpd_conf, :mime_conf

    def initialize(options={})
      # Set up WebServer's configuration files and logger here
      config_file = File.open("config/httpd.conf", 'r')
      @httpd_conf = HttpdConf.new(config_file.read)
      mime_file = File.open("config/mime.types", "r")
      @mime_conf = MimeTypes.new(mime_file.read)
      #puts @httpd_conf.inspect
      #puts @mime_conf.inspect

      # Do any preparation necessary to allow threading multiple requests
    end

    def start
      # Initialize a tcp server
      STDERR.puts "Listen to port " + @httpd_conf.port.to_s
      server = TCPServer.new('localhost', @httpd_conf.port)


      while true do 
        socket = server.accept
        thread = Thread.new{ worker(socket) }
      end

      # Close the socket, terminating the connection


      # Begin your 'infinite' loop, reading from the TCPServer, and
      # processing the requests as connections are made
    end

    private

    # thread function
    def worker (socket)
        request = Request.new(socket)

        response = handle_message(request)

        puts "---------- Response Message BEGIN -------------------"
        puts response.header
        puts "---------- Response Message END ---------------------"
        socket.print response.to_s
        socket.close
    end

    def handle_message (request)
      response = ""

      case request.http_method
      when "GET"
        response = send_resource(request)
      when "HEAD"
        response = generate_response(200, {})
      when "POST"
        response = generate_response(200, {})
      when "PUT"
        response = generate_response(200, {})
      else
        response = generate_response(404, {}) 
      end                  
    end

    def send_resource (request)   
      resource = Resource.new(request, @httpd_conf, @mime_conf)
      if resource.protected?

        return generate_response(401, {})
        # Return 403 if the resource is protected
        #return generate_response(403, {})
      else
        # Return 404 if file not exist
        file_path = resource.resolve_path
        return generate_response(404, {}) unless File.exist?(file_path)

        puts "----------- RETURN FILE BEGIN ---------------------"
        puts "Server return file " + file_path
        puts "----------- RETURN FILE END -----------------------"

        # Handle script and resource
        if resource.script_aliased?
          puts "Got script"
          result = IO.popen(file_path)
        else
          result = File.open(file_path, 'r')
        end
        # Return file content 
        return generate_response(200, {'BODY' => result.read})
      end

    end

    def generate_response (code, options)
      Response::Factory.create(code, options)
    end
  end


end

WebServer::Server.new.start

