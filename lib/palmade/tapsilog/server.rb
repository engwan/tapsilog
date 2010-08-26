module Palmade::Tapsilog
  class Server

    SeverityLevels = [:debug, :info, :warn, :error, :fatal]

    attr_reader :now

    def self.start(config, protocol = "")
      self.new(config).start(protocol)
    end

    def initialize(config)
      @config = config
    end

    def start(protocol = "")
      daemonize if @config['daemonize']
      start_server(protocol)
    end

    protected

    def daemonize
      if (child_pid = fork)
        puts "Forked PID #{child_pid}"
        exit!
      end
      Process.setsid

    rescue Exception
      puts "Platform (#{RUBY_PLATFORM}) does not appear to support fork/setsid; skipping" 
    end

    def start_server(protocol)
      EventMachine.run {
        EventMachine.add_periodic_timer(1) { update_now }
      }
    end

    def update_now
      @now = Time.now.strftime('%Y/%m/%d $H:%M:%S')
    end

  end
end
