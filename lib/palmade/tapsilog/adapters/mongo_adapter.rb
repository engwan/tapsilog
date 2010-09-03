require 'mongo'

module Palmade::Tapsilog::Adapters
  class MongoAdapter < BaseAdapter

    def write(log_message)
      service = log_message[1]
      coll = get_collection(service)

      coll.insert(log_to_hash(log_message))
    end

    def close
      unless @conn.nil?
        @conn.close if @conn.connected?
      end
    end

    protected

    def get_collection(service_name)
      service_name = (@services[service_name].nil?) ? 'default' : service_name
      service = @services[service_name]

      db_conn[service[:target]]
    end

    def log_to_hash(log_message)
      timestamp, service, pid, severity, message, tags = log_message
      log_hash = {
        :timestamp => timestamp,
        :service => service,
        :pid => pid,
        :severity => severity,
        :message => message,
        :created_at => Time.now
      }
      unless tags.nil? or tags.empty?
        log_hash[:tags] = Palmade::Tapsilog::Utils::query_string_to_hash(tags)
      end

      log_hash
    end

    def db_conn
      if @db.nil?
        mongo_conn = Mongo::Connection.new(@config[:host], @config[:port])
        db_name = @config[:database] || 'tapsilog'

        @db = mongo_conn.db(db_name)
        if @config[:user] and @config[:password]
          @db.authenticate(@config[:user], @config[:password])
        end
      end

      @db
    end


  end
end
