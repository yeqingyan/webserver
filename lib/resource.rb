module WebServer
	class Resource
		# protected, script: they are the boolean to tell the path is protected or it is a script
		# authconf: if resource is protected, authconf store the auth information.
		# resolve_path: resolved path
		attr_reader :request, :conf, :mimes, :protected, :authconf, :script, :resolve_path

		def initialize(request, httpd_conf, mimes)
			@request = request
			@conf = httpd_conf
			@mimes = mimes
			@protected = false
			@script = false
			@authconf = nil
			@resolve_path = ""

			# Get resolved path
			@resolve_path = resolve
			
			# protected or not
			if File.directory?(@resolve_path)
				file_dir = @resolve_path
			else
				file_dir = File.dirname(@resolve_path)
			end

			auth_filepath = File.join(file_dir, httpd_conf.access_file);
			if File.exist?(auth_filepath) && (!@resolve_path["protected"].nil?)
				@protected = true
				auth_file = File.open(auth_filepath);
				@authconf = AuthConf.new(auth_file.read)
			end
		end

		def resolve
	    	
	    	# Do not add directory_index if uri end with .abc 
	    	#if @request.uri == '/'
			#	resolve_string = "#{conf.document_root}/#{conf.directory_index}"
	    	if @request.uri[/\/$/]
	    		resolve_string = "#{conf.document_root}#{request.uri}/#{conf.directory_index}"
	    	else
	    		resolve_string = "#{conf.document_root}#{request.uri}"
	    	end

	    	# script_aliases replace
	    	# let's assume the script directory is under the document_root
	    	unless @conf.script_aliases.empty?
	    		@conf.script_aliases.each do |name|
	    			@script = true if resolve_string[name]
	    			resolve_string.gsub!(name, @conf.script_alias_path(name))
	    		end
	    	end
	    	# aliases replace
	    	unless @conf.aliases.empty?  
	    		@conf.aliases.each do |name|
	    			resolve_string.gsub!(name, @conf.alias_path(name))
	    		end
	    	end
	    	return resolve_string
	    end

	    def script_aliased?
			@script
	    end

	    def protected?
			@protected
	    end
		
		def authorized?(userinfo)
			puts "authorized "+ userinfo.inspect
			if @protected
				if userinfo.nil?
					return false
				else
					return authconf.user_match?(userinfo)
				end
			else
				return false
			end
		end

		def auth_type
			raise "AuthConf is NULL!" if @authconf == nil
			@authconf.auth_type
		end

		def auth_realm
			raise "AuthConf is NULL!" if @authconf == nil
			@authconf.auth_name
		end
	end
end

