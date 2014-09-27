require_relative 'configuration'

# Parses, stores, and exposes the values from the httpd.conf file
module WebServer

  class HttpdConf < Configuration
    def initialize(httpd_file_content)
        super

        @config_hash = Hash.new
        @config_hash['ScriptAlias'] = Hash.new
        @config_hash['Alias'] = Hash.new

        httpd_file_content.split("\n").each do |config_line| 
            config_line.strip!
            next if config_line.empty? || config_line[0] == '#'
            name,value = config_line.split(' ', 2)
            if name == "ScriptAlias"
                alias_name,alias_value = value.split(' ', 2)
                @config_hash['ScriptAlias'][alias_name] = alias_value.gsub(/["\n]/, '')
            elsif name == 'Alias'
                alias_name,alias_value = value.split(' ', 2)
                @config_hash['Alias'][alias_name] = alias_value.gsub(/["\n]/, '')              
            else
                @config_hash[name] = value.gsub(/["\n]/, '')
            end
        end

    end

    # Returns the value of the ServerRoot
    def server_root 
        @config_hash['ServerRoot']
    end

    # Returns the value of the DocumentRoot
    def document_root
        @config_hash['DocumentRoot']
    end

    # Returns the directory index file
    def directory_index
        @config_hash['DirectoryIndex']
    end

    # Returns the *integer* value of Listen
    def port
        @config_hash['Listen'].to_i
    end

    # Returns the value of LogFile
    def log_file
        @config_hash['LogFile']
    end

    # Returns the name of the AccessFile 
    def access_file_name
        @config_hash['AccessFileName']
    end

    # Returns an array of ScriptAlias directories
    def script_aliases
        @config_hash['ScriptAlias'].keys
    end

    # Returns the aliased path for a given ScriptAlias directory
    def script_alias_path(path)
        @config_hash['ScriptAlias'][path]
    end

    # Returns an array of Alias directories
    def aliases
        @config_hash['Alias'].keys
    end

    # Returns the aliased path for a given Alias directory
    def alias_path(path)
        @config_hash['Alias'][path]
    end
  end
end
