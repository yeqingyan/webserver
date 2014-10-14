require 'digest'
require 'base64'

module WebServer
  class Htaccess
    def initialize(auth_file_content)

      @config_hash = {}
      @pass_map = {}

      auth_file_content.split("\n").each do |config_line| 
        config_line.strip!
        next if config_line.empty? || config_line[0] == '#'
        key,value = config_line.split(' ', 2)
        next if value.nil?
        @config_hash[key] = value
      end


      if File.exist?(auth_user_file)
        read_passwd(auth_user_file) 
      end

    end

    def read_passwd(filepath)
      pass_file = File.open(filepath, "r")
      pass_file.readlines.each do |line|
        line.strip!
        next if line.empty?
        #name,key = Base64.decode64(line).split(':')
        name,key = line.split(':')
        @pass_map[name] = key[/(?<=}).*/]
      end
    end

      # Returns the value
      def auth_user_file
        @config_hash["AuthUserFile"]
      end

      def auth_type
        @config_hash["AuthType"]
      end

      def auth_name
        @config_hash["AuthName"].gsub('"', '')
      end

      def require_user
        @config_hash["Require"]
      end

      def authorized?(userinfo)
        puts "user_match? get userinfo:"+userinfo.inspect
        client_user,client_pass = Base64.decode64(userinfo).split(':')
        puts @pass_map.inspect

        if(require_user != 'valid-user')
            # =>  check user in the require field
            return false unless require_user.split(' ').include?(client_user)
          end

          server_pass = @pass_map[client_user]
          return false if ((server_pass == nil) || (client_pass == nil))

          puts "Client PASS is " + client_pass
          puts "Server PASS is " + server_pass
          return (server_pass == Digest::SHA1.base64digest(client_pass))
      end

      def users
        @pass_map.keys
      end
  end
end