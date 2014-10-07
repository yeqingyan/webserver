require_relative 'configuration'

# Parses, stores and exposes the values from the mime.types file
module WebServer
  class MimeTypes < Configuration
    def initialize(mime_file_content)
   		
   		@config_hash = {"random" => "text/plain"}

   		mime_file_content.split("\n").each do |config_line| 
   			config_line.strip!
   			next if config_line.empty? || config_line[0] == '#'
   			type,ext = config_line.split(' ', 2)
        next if ext.nil?
   			if ext.split.is_a?(String)
   				@config_hash[ext] = type
   			else
   				ext.split(' ').each do |item|
            @config_hash[item] = type
				  end
   			end
   		end
    end
    
    # Returns the mime type for the specified extension
    def for_extension(extension)
    	@config_hash[extension]
    end
  end
end
