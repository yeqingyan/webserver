require 'socket'
Dir.glob('lib/**/*.rb').each do |file|
  require file
end

module WebServer
  class Server
    DEFAULT_PORT = 2468

    def initialize(options={})
      # Set up WebServer's configuration files and logger here
      @conf_file = File.new("config/httpd.conf")
      @conf = WebServer::HttpdConf.new(@conf_file.read)
      @mime_file = File.new("config/mime.types")
      @mime = WebServer::MimeTypes.new(@mime_file.read)

      p @mime

      # Do any preparation necessary to allow threading multiple requests
    end

    def start
      # Begin your 'infinite' loop, reading from the TCPServer, and
      # processing the requests as connections are made
    end

    private
  end
end

WebServer::Server.new.start
