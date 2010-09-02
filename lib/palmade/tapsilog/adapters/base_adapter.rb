module Palmade::Tapsilog::Adapters
  class BaseAdapter

    def initialize(config)
      @config = config
      initialize_services
    end

    def write(log_message)
    end

    def flush
    end

    def close
    end

    protected

    def initialize_services
      @services = {}

      @config[:services].each do |service|
        service_name = service['service']
        @services[service_name] = {
          :target => service['target']
        }
      end
    end

  end
end
