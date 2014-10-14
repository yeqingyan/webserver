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
	    	begin 
		    	request = Request.new(@socket)

		    	response = handle_message(request)
		    	$logger.log(request, response)
		    	@socket.print response.to_s
	    	rescue => exception
	    		STDERR.puts "GOT ERROR!"
  				puts exception.backtrace
		    	response = generate_response(500, {}) 
		    	@socket.print response.to_s
		    end    
	    end

	    def handle_message (request)
	    	response = ""

	    	case request.http_method
	    	when "GET"
	    		response = send_resource(request)
	    	when "HEAD"
	    		response = generate_response(200, {})
	    	when "POST"
	    		response = send_resource(request)
	    	when "PUT"
	    		response = store_resource(request)
	    	else
	    		response = generate_response(400, {}) 
	    	end   
		               
	    end

	    def send_resource (request)   
	    	resource = Resource.new(request, $httpd_conf, $mime_conf)

	    	if resource.protected? && (request.headers['AUTHORIZATION'] == nil)
	    		# return 401 ask for authrization
    			return generate_response(401, {'TYPE' => resource.auth_type, 'REALM' => resource.auth_realm})
    		elsif resource.protected? && (resource.authorized?(request.headers['AUTHORIZATION']) == false)
    			# return 403 if password is wrong
    			return generate_response(403, {})				
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

		        	if request.http_method == 'POST'
		        		script_cmd = file_path + ' ' + request.body
		        	else
		        		script_cmd = file_path
		        	end

		        	result = { 'BODY' => IO.popen(script_cmd).read }
		        else
		        	# return 304 if file not modified
		        	if request.headers['IF_MODIFIED_SINCE']
		        		client_mtime = request.headers['IF_MODIFIED_SINCE']
		        		if client_mtime == File.mtime(file_path).gmtime.strftime('%a, %e %b %Y %H:%M:%S %Z')
		        			return generate_response(304, {})
		        		end
		        	end

		        	file_content = File.open(file_path, 'r').read
		        	last_mtime = File.mtime(file_path).gmtime.strftime('%a, %e %b %Y %H:%M:%S %Z')
		        	result = { 'BODY' => file_content, 'AGE' => 0, 
		        			'LAST_MODIFIED' => last_mtime, 'TYPE' => File.extname(file_path)}
		        end
		        # Return file content 
		        return generate_response(200, result)
		    end
		end

		def store_resource (request)
			# 1 get uri
			resource = Resource.new(request, $httpd_conf, $mime_conf)
			
			# 2 have permission?
			if resource.protected? && (request.headers['AUTHORIZATION'] == nil)
	    		# return 401 ask for authrization
    			return generate_response(401, {'TYPE' => resource.auth_type, 'REALM' => resource.auth_realm})
    		elsif resource.protected? && (resource.authorized?(request.headers['AUTHORIZATION']) == false)
    			# return 403 if password is wrong
    			return generate_response(403, {})				
	    	else
				# 3 uri exist? return 404 if uri is point to index.html 
	        	file_path = resource.resolve_path
	        	return generate_response(404, {}) if (File.basename(file_path) == 'index.html')
 				# 4 create resource? modified or created?
 				# return 200
 				if File.exist?(file_path)
 					put_file = File.open(file_path, 'w')
 					if request.body.nil?
 						put_file.write("")
 					else
 						put_file.write(request.body)
 					end
 					generate_response(200, {})
 				else
 					put_file = File.open(file_path, 'w')
 					if request.body.nil?
 						put_file.write("")
 					else
 						put_file.write(request.body)
 					end
 					generate_response(201, {})
 				end 				
 			end
		end

		def generate_response (code, options)
			Response::Factory.create(code, options)
		end
	end
end
