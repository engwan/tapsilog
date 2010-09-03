module Palmade::Tapsilog
  class Server

    SeverityLevels = [:debug, :info, :warn, :error, :fatal]

    attr_reader :now

    def self.start(config, protocol = Palmade::Tapsilog::Protocol)
      @config = config
      @protocol = protocol
      @tsocks = []
      @usocks = []
      @queue = []
      boot
    end

    def self.add_log(log)
      @queue << ([@now] + log)
    end

    def self.key
      @config[:key].to_s
    end

    protected

    def self.boot
      write_pid_file if @config[:pidfile]
      daemonize if @config[:daemonize]

      load_adapter

      trap("INT") { exit }
      trap("TERM") { exit }
      trap("HUP") { throw :hup }

      start_server
    end

    def self.write_pid_file
      if File.exists?(@config[:pidfile])
        begin
          pid = File.read(@config[:pidfile]).strip
          Process.kill(0, pid.to_i)
          raise "Another instance of tapsilog seems to be running! (#{pid})"
        rescue Errno::ESRCH
          File.delete(@config[Cpidfile])
          STDERR.puts "Stale PID (#{pid}) removed"
        end
      end

      File.open(@config[Cpidfile],'w+') {|fh| fh.puts $$}
    end

    def self.daemonize
      if (child_pid = fork)
        puts "Forked PID #{child_pid}"
        exit!
      end
      Process.setsid

    rescue Exception
      puts "Platform (#{RUBY_PLATFORM}) does not appear to support fork/setsid; skipping" 
    end

    def self.load_adapter
      raise "Missing logs section in config file" unless @config[:logs]

      adapter_name = @config[:logs][:adapter] || "file"
      class_name = "#{adapter_name.capitalize}Adapter"
      adapter = Palmade::Tapsilog::Adapters.const_get(class_name) 
      @adapter = adapter.new(@config[:logs])
    end

    def self.start_server
      prepare_server
      begin
        EventMachine.run {
          start_servers
          EventMachine.add_periodic_timer(1) { update_now }
          EventMachine.add_periodic_timer(@config[:interval]) { write_queue }
          EventMachine.add_periodic_timer(@config[:syncinterval]) { flush_queue }
        }
      ensure
        cleanup
      end
    end

    def self.prepare_server
      if @config[:socket]
        @usocks = @config[:socket]
        @usocks = [ @usocks ] unless @usocks.is_a? Array

        @usocks.each do |usock|
          raise "Socket file already exists! (#{usock})" if File.exists?(usock)
        end
      end

      if @config[:host]
        @tsocks = @config[:host]
        @tsocks = [ @tsocks ] unless @tsocks.is_a? Array

        @tsocks.each do |tsock|
          raise "Port already in use! #{tsock}:#{@config[:port]}" if Utils.is_port_open?(tsock, @config[:port])
        end
      end
    end

    def self.start_servers
      @usocks.each do |usock|
        raise "Socket file already exists! (#{usock})" if File.exists?(usock)
        
        STDERR.puts "Listening to: #{usock}"
        EventMachine.start_unix_domain_server(usock, @protocol)
        File.chmod(0777, usock)
      end
      
      @tsocks.each do |tsock|
        raise "Port already in use! #{tsock}:#{@config[:port]}" if Utils.is_port_open?(tsock, @config[:port])

        STDERR.puts "Listening to: #{tsock}:#{@config[:port]}"
        EventMachine.start_server(tsock, @config[:port], @protocol)
      end
    end

    def self.cleanup
      @adapter.close unless @adapter.nil?
      @usocks.each do |usock|
        File.delete(usock) if File.exists?(usock)
      end
      File.delete(@config[:pidfile]) if @config[:pidfile] and File.exists?(@config[:pidfile])
    end

    def self.update_now
      @now = Time.now.strftime('%Y/%m/%d %H:%M:%S')
    end

    def self.write_queue
      @queue.each do |log_message|
        next unless SeverityLevels.include?(log_message[3].to_sym)
        @adapter.write(log_message)
      end
      @queue.clear
    end

    def self.flush_queue
      @adapter.flush
    end

  end
end
