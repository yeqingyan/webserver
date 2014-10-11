module WebServer
  class Resource
    attr_reader :request, :conf, :mimes

    def initialize(request, httpd_conf, mimes)
      @request = request
      @conf = httpd_conf
      @mimes = mimes

      resource = resolve
    end

    def resolve
    	resolve_string = @conf.document_root + @request.uri
 
        if !@conf.script_aliases.empty? 
    		@conf.script_aliases.each do |path|
    			resolve_string.gsub!(path, @conf.script_alias_path(path))
    		end
        end
    	
    	if !@conf.aliases.empty?
    		@conf.aliases.each do |path|
    			resolve_string.gsub!(path, @conf.alias_path(path))
                resolve_string = resolve_string + "/" + @conf.directory_index
    		end
    	end

    	if !script_aliased? && @conf.aliases.empty?
    		resolve_string = @conf.document_root + @request.uri + "/" + @conf.directory_index
    	end

    	resolve_string
    end

    def script_aliased?
        if @conf.script_aliases.empty?
           return false
        else
            @conf.script_aliases.each do |path|
                if @request.uri[path] = path
                    return true
                end
            end 
        end

        return false
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
