require 'fileutils'

module WebServer
  class Logger
    attr_accessor :echo, :log_file

    # Takes the absolute path to the log file, and any options
    # you may want to specify.  I include the option :echo to 
    # allow me to decide if I want my server to print out log
    # messages as they get generated
    def initialize(log_file_path, options={})
        @echo = false

        if options['ECHO']
            @echo = options['ECHO']
        end

        # create dir
        logdir = File.dirname(log_file_path)
        unless File.directory?(logdir)
          FileUtils.mkdir_p(logdir)
        end
        @log_file = File.open(log_file_path, 'w')
    end

    # Log a message using the information from Request and 
    # Response objects
    def log(request, response)
        msg = ""
        msg += request.show
        msg += "---------- Response Message BEGIN -------------------\n"
        msg += response.header
        msg += "---------- Response Message END ---------------------\n"
        if @echo
            puts msg
        end
        @log_file.write(msg)

    end

    # Allow the consumer of this class to flush and close the 
    # log file
    def close
        log_file.close
    end
  end
end
