module Palmade::Tapsilog
  class Protocol < EventMachine::Connection
    Ci = 'i'.freeze
    Rcolon = /:/
    MaxMessageLength = 8192

    LoggerClass = Palmade::Tapsilog::Server

    def post_init
      setup
    end

    def setup
      @length = nil
      @logchunk = ''
      @authenticated = nil
    end

    def receive_data(data)
      @logchunk << data

      while @length.nil? and @logchunk.length > 7
        return false unless get_length

        if @length and @logchunk.length > @length
          get_message
        end
      end
    end

    protected

    def get_length
      l = @logchunk[0..3].unpack(Ci).first
      ck = @logchunk[4..7].unpack(Ci).first

      if l == ck and l < MaxMessageLength
        @length = l +7
        return true
      else
        peer = get_peername
        peer = peer ? ::Socket.unpack_sockaddr_in(peer)[1] : 'UNK'

        if l == ck
          LoggerClass.add_log([:default, $$.to_s, :error, "Max Length Exceeded from #{peer} -- #{l}/#{MaxMessageLength}"])
        else
          LoggerClass.add_log([:default, $$.to_s, :error, "Checksum failed from #{peer} -- #{l}/#{ck}"])
        end

        close_connection
        return false
      end
    end

    def get_message
      msg = @logchunk.slice!(0..@length).split(Rcolon,5)

      unless @authenticated
        @authenticated = authenticate_message(msg)
      end

      if @authenticated
        msg[0] = nil
        msg.shift

        msg[0] = msg[0].to_s.gsub(/[^a-zA-Z0-9\-\_\.]\s/, '').strip

        LoggerClass.add_log(msg)
        @length = nil
      end
    end

    def authenticate_message(msg)
      if msg.last == LoggerClass.key
        return true
      else
        peer = get_peername
        peer = peer ? ::Socket.unpack_sockaddr_in(peer)[1] : 'UNK'

        LoggerClass.add_log([:default, $$.to_s, :error, "Invalid key from #{peer} -- #{msg.last}"])
        close_connection
        return false
      end
    end

  end
end
