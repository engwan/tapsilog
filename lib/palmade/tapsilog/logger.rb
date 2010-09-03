module Palmade::Tapsilog
  class Logger < Client
    LOG_LEVEL_TEXT = [ 'debug', 'info', 'warn', 'error', 'fatal', 'unknown' ]

    DEBUG, INFO, WARN, ERROR, FATAL, UNKNOWN = (0..5).to_a
    
    attr_accessor :level

    def initialize(*args, &block)
      super(*args, &block)
      @level = INFO
    end

    def info?
      @level <= INFO
    end
    
    def info(progname = nil, tags = {}, &block)
      add(INFO, nil, progname, tags, &block)
    end
    
    def debug?
      @level <= DEBUG
    end

    def debug(progname = nil, tags = {}, &block)
      add(DEBUG, nil, progname, tags, &block)
    end

    def error?
      @level <= ERROR
    end

    def error(progname = nil, tags = {}, &block)
      add(ERROR, nil, progname, tags, &block)
    end

    def fatal?
      @level <= FATAL
    end

    def fatal(progname = nil, tags = {}, &block)
      add(FATAL, nil, progname, tags, &block)
    end

    def warn?
      @level <= WARN
    end

    def warn(progname = nil, tags = {}, &block)
      add(WARN, nil, progname, tags, &block)
    end

    def add(severity, message = nil, progname = nil, tags = {}, &block)
      case severity
      when 'authentication'
        return log_without_rails_extensions(severity, message)
      when String, Symbol
        severity = LOG_LEVEL_TEXT.index(severity.to_s.downcase) || UNKNOWN
      when nil
        severity = UNKNOWN
      end

      if severity < @level
        return true
      end

      log_level_text = LOG_LEVEL_TEXT[severity]
      progname ||= @service
      message = if message.nil?
        if block_given?
          message = yield
        else
          progname
        end
      else
        message.to_s
      end

      log_without_rails_extensions(log_level_text, message, tags)
    end
    
    alias_method :log_without_rails_extensions, :log
    alias_method :log, :add
  end
end

