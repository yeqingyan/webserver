require_relative 'configuration'

# Parses, stores, and exposes the values from the httpd.conf file
module WebServer
  class HttpdConf < Configuration
    def initialize(httpd_file_content)
        @config_hash = Hash.new
        @script_alias_hash = Hash.new
        @alias_hash = Hash.new


        @config_lines = httpd_file_content.split("\n")
        @config_lines.each do |line|
            next if line.strip.empty?
            tokens = line.split(" ")
                header = tokens[0].split("")
                next if header[0] == "#"
                if tokens[0] == "ScriptAlias"
                    @script_alias_hash[tokens[1]] = tokens[2].tr("\"", "")
                elsif tokens[0] == "Alias"
                    @alias_hash[tokens[1]] = tokens[2].tr("\"", "")
                else
                    @config_hash[tokens[0]] = tokens[1].tr("\"", "")
                end
        end
    end

    # Returns the value of the ServerRoot
    def server_root
        @config_hash["ServerRoot"]
    end

    # Returns the value of the DocumentRoot
    def document_root
        @config_hash["DocumentRoot"]
    end

    # Returns the directory index file
    def directory_index
        @config_hash["DirectoryIndex"]
    end

    # Returns the *integer* value of Listen
    def port
        @config_hash["Listen"].to_i
    end

    # Returns the value of LogFile
    def log_file
        @config_hash["LogFile"]
    end

    # Returns the name of the AccessFile 
    def access_file_name
        @config_hash["AccessFileName"]
    end

    # Returns an array of ScriptAlias directories
    def script_aliases
        @script_alias_hash.keys
    end

    # Returns the aliased path for a given ScriptAlias directory
    def script_alias_path(path)
        @script_alias_hash[path]
    end

    # Returns an array of Alias directories
    def aliases
        @alias_hash.keys
    end

    # Returns the aliased path for a given Alias directory
    def alias_path(path)
        @alias_hash[path]
    end
  end
end

#conf = WebServer::HttpdConf.new("ServerRoot \"/Users/jrob/workspace/server/\"")
#p conf.server_root

#p "1234".to_i