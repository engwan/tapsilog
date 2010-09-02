module Palmade::Tapsilog::Adapters
  class FileAdapter

    def initialize(config)
      @config = config
      initialize_services
    end

    def write(log_message)
      service = log_message[1]
      file = get_file_descriptor(service)
      file.puts(log_message.join("|"))
    end

    def flush
      @services.each do |name, service|
        fd = service[:file]
        unless fd.nil?
          fd.fsync if fd.fileno > 2
        end
      end
    end    

    def close
      @services.each do |name, service|
        fd = service[:file]
        unless fd.nil?
          fd.close unless fd.closed?
        end 
      end
    end

    protected
 
    def initialize_services
      @services = {}
      
      @config[:services].each do |service|
        service_name = service['service']
        @services[service_name] = {
          :logfile => service['logfile']
        }
      end
    end 

    def get_file_descriptor(service_name)
      service_name = (@services[service_name].nil?) ? 'default' : service_name
      service = @services[service_name]

      if service[:file].nil?
        open_file_descriptor(service)
      else
        service[:file]
      end
    end

    def open_file_descriptor(service)
      logfile = service[:logfile]

      if logfile =~ /^STDOUT$/i
        service[:file] = $stdout
      elsif logfile =~ /^STDERR$/i
        service[:file] = @stderr
      else
        service[:file] = File.open(logfile, 'ab+')
      end
    end

  end
end
