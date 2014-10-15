require_relative 'request'
require_relative 'response'

# This class will be executed in the context of a thread, and
# should instantiate a Request from the client (socket), perform
# any logging, and issue the Response to the client.
module WebServer
  class Worker
    # Takes a reference to the client socket and the logger object
    def initialize(client_socket, server=nil)
    	@socket = client_socket
    	@server = server

    	process_request
    end

    # Processes the request
    def process_request
    	request = Request.new(@socket)
    	resource = Resource.new(request, $conf, $mime)
    	#Simple index file return
    	path = resource.resolve
    	p path

    	file_content = ""
    	if File.exists?(path)
    		file_content = File.open(path, 'r').read
    	else
    		p "malformed uri"
    	end
    	modified = File.mtime(path).gmtime.strftime("%a, %e, %b %Y %H:%M:%S %Z")
    	response = {"BODY" => file_content, "AGE" => 0, "LAST_MODIFIED" => modified, 
    	"TYPE" => File.extname(path)}

    	Response::Factory.create(200, response)

    	@socket.puts(file_content)
    end
  end
end
