module WebServer
  class Resource
    # protected, script: they are the boolean to tell the path is protected or it is a script
    # authconf: if resource is protected, authconf store the auth information.
    # resolve_path: resolved path
    attr_reader :request, :conf, :mimes, :protected, :authconf, :script, :resolve_path, :alias

    def initialize(request, httpd_conf, mimes)
      @request = request
      @conf = httpd_conf
      @mimes = mimes
      @protected = false
      @script = false
      @authconf = nil

      resolve      
      protected?

    end

    def resolve
      @resolve_path ||= begin

        check_script(@request.uri)
        check_alias(@request.uri)

        # replace script path
        if script_aliased?
          resolve_string = @request.uri
          @conf.script_aliases.each do |name|
            resolve_string.gsub!(name, @conf.script_alias_path(name))
          end
        else
          # add index.html if the uri is directory
          if File.extname(@request.uri) == ""
            resolve_string = File.join(@request.uri, @conf.directory_index)
          else 
            resolve_string = @request.uri
          end

          # replace alias 
          if alias_aliased?           
            @conf.aliases.each do |name|
              resolve_string.gsub!(name, @conf.alias_path(name))
            end
          else
            # add document root to the head of the file
            puts @conf.document_root
            resolve_string = File.join(@conf.document_root, resolve_string)
          end
        end

        resolve_string
      end
    end

    def script_aliased?
      @script
    end

    def alias_aliased?
      @alias
    end

    def protected?
      @protected ||= begin
        @protected = false

        # check access file
        if File.directory?(@resolve_path)
          file_dir = @resolve_path
        else
          file_dir = File.dirname(@resolve_path)
        end

        file_dir = file_dir.gsub("\n", '')
        auth_filepath = File.join(file_dir, @conf.access_file_name);
        if File.exist?(auth_filepath)
          @protected = true
          auth_file = File.open(auth_filepath);
          @authconf = Htaccess.new(auth_file.read)
        end
        @protected
      end
    end

    def authorized?(userinfo)
      puts "authorized "+ userinfo.inspect
      if @protected
        return false if userinfo.nil?
        return authconf.authorized?(userinfo.split(' ')[1])
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

    def check_script(path)
      unless @conf.script_aliases.empty?
        @conf.script_aliases.each do |name|
          if path[name]
            @script = true 
          end
        end
      end
    end 

    def check_alias(path)
      unless @conf.aliases.empty?
        @conf.aliases.each do |name|
          if path[name]
            @alias = true 
          end
        end
      end
    end 
  end
end
