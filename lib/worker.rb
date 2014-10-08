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
	    end

	    # Processes the request
	    def process_request
	    	request = Request.new(@socket)

	    	response = handle_message(request)

	    	puts "---------- Response Message BEGIN -------------------"
	    	puts response.header
	    	puts "---------- Response Message END ---------------------"
	    	@socket.print response.to_s
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
	    	resource = Resource.new(request, $httpd_conf, $mime_conf)
	    	if resource.protected? && (resource.authorized?(request.headers['AUTHORIZATION']) == false)
	    		return generate_response(401, {'TYPE' => resource.auth_type, 'REALM' => resource.auth_realm})
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
