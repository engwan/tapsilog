module Palmade::Tapsilog
  class Client

    DEFAULT_OPTIONS = {
      :async => false
    }

    def initialize(service = 'default', target = '127.0.0.1:19070', key = nil, instance_key = nil, options = { })
      @service = service.to_s
      @instance_key = instance_key

      @target = target
      @key = key

      @options = DEFAULT_OPTIONS.merge(options)
      @conn = Palmade::Tapsilog::Conn.new(@target, @key, @options[:async])
    end

    def log(severity, msg, tags = {}, ts = nil)
      ts = Time.now if ts.nil?
      conn_log(severity, msg, tags, ts)
      self
    end

    def flush
      @conn.flush
    end

    def close
      @conn.close
    end

    def closed?
      @conn.closed?
    end

    def reconnect
      @conn.reconnect!
    end

    protected

    def conn_log(severity, msg, tags = {}, ts = nil)
      ts = Time.now if ts.nil?
      @conn.log(@service, @instance_key || $$, severity, msg, tags, ts)
    end
  end
end
