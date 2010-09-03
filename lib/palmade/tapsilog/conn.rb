require 'cgi'

module Palmade::Tapsilog
  class Conn
    attr_reader :socket

    MAX_TRIES = 6

    def initialize(target, key, buffered = false)
      if target =~ /(.+)\:(\d+)$/i
        @host = $~[1]
        @port = $~[2]
      else
        @host = target
        @port = nil
      end
      @key = key
      @socket = nil
      @buffered = buffered
    end

    def connect(host, port)
      if @socket.nil? || @socket.closed?
        real_connect(host, port)
        log('default', $$, 'authentication', @key)
      else
        @socket
      end
    end

    def log(service, instance_key, severity, message, tags = {}, ts = nil)
      tries = 0
      connect(@host, @port)

      ts = Time.now if ts.nil?
      tag_string = Utils::hash_to_query_string(tags)

      fullmsg = ":#{service}:#{instance_key}:#{severity}:#{message}:#{tag_string}"

      # Truncate below the 8192 limit on Tapsilog service
      fullmsg = fullmsg[0,8190] if fullmsg.size > 8190

      len = [fullmsg.length].pack('i')

      begin
        # first 8-bytes, is len and checksum
        write "#{len}#{len}#{fullmsg}"
      rescue Exception => e
        STDERR.puts "Failed to write to server! Retrying... (#{tries})" +
                    "#{e.class.name}: #{e.message}\n#{e.backtrace.join("\n")}"

        if tries < MAX_TRIES
          tries += 1
          close_possibly_dead_conn(tries)
          reconnect
          retry
        else
          raise e
        end
      end

      len
    end

    def flush
      @socket.flush unless @socket.nil?
    end

    def close
      @socket.nil? ? nil : @socket.close rescue nil
    end

    def closed?
      @socket.nil? ? true : @socket.closed?
    end

    def reconnect!
      close unless closed?
      connect(@host, @port)
    end
    alias :reconnect :reconnect!

    protected

    def real_connect(host, port)
      tries = 0
      begin
        if host =~ /^\/(.+)/
          @socket = UNIXSocket.new(host)
        else
          @socket = TCPSocket.new(host, port)
          @socket.sync = !@buffered
        end
        raise "Unable to create socket!" if @socket.nil?
      rescue Exception => e
        STDERR.puts "Failed to establish connection with server! Retrying... (#{tries})" + 
                    " #{e.class.name}: #{e.message}\n#{e.backtrace.join("\n")}"

        if tries < MAX_TRIES
          tries += 1
          close_possibly_dead_conn(tries)
          retry
        else
          raise e
        end
      end

      @socket
    end

    def write(msg, flush = false)
      conn_timeout do
        wrtlen = @socket.write(msg)
      end
      self.flush if flush
      @socket
    end

    def close_possibly_dead_conn(tries = 0)
      close unless @socket.nil? || closed?

      @socket = nil
      select(nil,nil,nil, tries * 0.2) if tries > 0
      @socket
    end

    def conn_timeout(&block)
      ::Timeout::timeout(6, Palmade::Tapsilog::Timeout, &block)
    end

  end
end
