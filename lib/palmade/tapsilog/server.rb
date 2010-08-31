module Palmade::Tapsilog
  module Server

    SeverityLevels = [:debug, :info, :warn, :error, :fatal]

    attr_reader :now

    def self.start(config, protocol = Palmade::Tapsilog::Protocol)
      @config = config
      @protocol = protocol
      boot
    end

    def self.add_log(log)
      STDERR.puts "#{@now}: #{log}"
    end

    def self.key
      @config[:key].to_s
    end

    protected

    def self.boot
      daemonize if @config['daemonize']
      start_server
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

    def self.start_server
      EventMachine.run {
        EventMachine.start_server('127.0.0.1', '12345', @protocol)
        EventMachine.add_periodic_timer(1) { update_now }
        EventMachine.add_periodic_timer(@config[:interval]) { write_queue }
        EventMachine.add_periodic_timer(@config[:syncinterval]) { flush_queue }
      }
    end

    def self.update_now
      @now = Time.now.strftime('%Y/%m/%d %H:%M:%S')
    end

    def self.write_queue
    end

    def self.flush_queue
    end

  end
end
