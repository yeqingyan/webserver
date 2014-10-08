require_relative 'configuration'
require 'digest'
require 'base64'

# Parses, stores and exposes the values from the mime.types file
module WebServer
  class AuthConf < Configuration
    def initialize(auth_file_content)
   		
   		@config_hash = {}
      @pass_map = {}

   		auth_file_content.split("\n").each do |config_line| 
   			config_line.strip!
   			next if config_line.empty? || config_line[0] == '#'
   			key,value = config_line.split(' ', 2)
        next if value.nil?
   			#if ext.split.is_a?(String)
   			@config_hash[key] = value
   			#else
   			#	ext.split(' ').each do |item|
        #    @config_hash[item] = type
				#  end
   		end


      if File.exist?(get_authfile)
        read_passwd(get_authfile) 
      end

    end

    def read_passwd(filepath)
      pass_file = File.open(filepath, "r")
      pass_file.readlines.each do |line|
        line.strip!
        next if line.empty?
        name,key = line.split(':')
        @pass_map[name] = key
      end
    end
    
    # Returns the value
    def get_authfile
    	@config_hash["AuthUserFile"]
    end

    def auth_type
      @config_hash["AuthType"]
    end

    def auth_name
      @config_hash["AuthName"]
    end

    def auth_require
      @config_hash["Require"]
    end

    def user_match?(userinfo)
      # userinfo = "Basic dGVzdDp0ZXN0"
      # get client user passwd.
      puts "user_match? get userinfo:"+userinfo.inspect
      client_user,client_pass = Base64.decode64(userinfo.split(' ')[1]).split(':')
      puts @pass_map.inspect
      server_pass = @pass_map[client_user]
      return false if server_pass == nil

      puts "Client PASS is " + client_pass
      puts "Server PASS is " + server_pass
      return (server_pass == Digest::SHA1.base64digest(client_pass))
    end
  end
end
