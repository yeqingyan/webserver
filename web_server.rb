require 'socket'
Dir.glob('lib/**/*.rb').each do |file|
  require file
end
require 'ruby-debug'

module WebServer

  class Server
    def initialize(options={})
      # Set up WebServer's configuration files and logger here
      # Set up global variable config_file and mime_file
      config_file = File.open("config/httpd.conf", 'r')
      $httpd_conf = HttpdConf.new(config_file.read)
      mime_file = File.open("config/mime.types", "r")
      $mime_conf = MimeTypes.new(mime_file.read)

      # Do any preparation necessary to allow threading multiple requests
    end

    def start
      # Initialize a tcp server
      STDERR.puts "Listen to port " + $httpd_conf.port.to_s
      server = TCPServer.new('localhost', $httpd_conf.port)


      loop do
        Thread.start(server.accept) do |client|
          worker = Worker.new(client, nil)
          worker.process_request
          # Close the socket, terminating the connection
          client.close
        end
      end




      # Begin your 'infinite' loop, reading from the TCPServer, and
      # processing the requests as connections are made
    end

    private


  end


end

WebServer::Server.new.start

