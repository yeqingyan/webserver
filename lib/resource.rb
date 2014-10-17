module WebServer
  class Resource
    attr_reader :request, :conf, :mimes

    def initialize(request, httpd_conf, mimes)
      @request = request
      @conf = httpd_conf
      @mimes = mimes
      @script = false

      resource = resolve
    end

    def resolve
    	unless @request.uri == "/"
            resolve_string = @conf.document_root + @request.uri
        else
            resolve_string = @conf.document_root + @conf.directory_index
        end

        unless @conf.script_aliases.empty? 
    		@conf.script_aliases.each do |path|
    			if resolve_string.gsub!(path, @conf.script_alias_path(path))
                    @script = true;
                end
    		end
        end
    	
    	unless @conf.aliases.empty?
    		@conf.aliases.each do |path|
    			resolve_string.gsub!(path, @conf.alias_path(path))
            end
    	end

        if resolve_string[-1] == "/"
            resolve_string = resolve_string + @conf.directory_index
        end
        resolve_string.gsub!("//", "/")
    	resolve_string
    end

    def script_aliased?
        @script
    end

    def protected?
        @request.uri.include? "protected"
    end

    def authorized?(uid)
        # Checks for WTaccess file from parent directory and down
        # Parse file
        # Get credentials from user
        # Check credentials against htpasswd
        # parse htpasswd

    	access_file = @conf.access_file_name

        #placeholder for real authentication
        if protected?
            return uid[:username] == "valid_name" && uid[:password] == "valid_pwd"
        end
        return true
    end


  end
end
