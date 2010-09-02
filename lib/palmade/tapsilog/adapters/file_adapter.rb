module Palmade::Tapsilog::Adapters
  class FileAdapter < BaseAdapter

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
 
    def get_file_descriptor(service_name)
      service_name = (@services[service_name].nil?) ? 'default' : service_name
      service = @services[service_name]

      if service[:file].nil?
        service[:file] = open_file_descriptor(service)
      end

      service[:file]
    end

    def open_file_descriptor(service)
      logfile = service[:target]

      if logfile =~ /^STDOUT$/i
        $stdout
      elsif logfile =~ /^STDERR$/i
        $stderr
      else
        File.open(logfile, 'ab+')
      end
    end

  end
end
