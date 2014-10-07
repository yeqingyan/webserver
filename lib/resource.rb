module WebServer
	class Resource
		attr_reader :request, :conf, :mimes

		def initialize(request, httpd_conf, mimes)
			@request = request
			@conf = httpd_conf
			@mimes = mimes

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

	    	false unless @conf.script_aliases

	    	@conf.script_aliases.each do |name|
	    		if @request.uri[name]
	    			return true
	    		end
	    	end
	    	false
	    end

	    def protected?
	    	!@request.uri["protected"].nil?
	    end
		
		def authorized?(userinfo)
			if protected?
				(userinfo[:username] == "valid_name") && (userinfo[:password] == "valid_pwd")
			else
				true
			end
		end
	end
end

