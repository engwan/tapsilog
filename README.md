## Tapsilog, an asynchronous logging service

  Tapsilog is a super customized fork of Analogger. Tapsilog allows you to attach tags to log messages so that it can be searched easily.
  Currently, Tapsilog supports files and mongodb as storage backend.

**Supported adapters**
  
  - file - Logs to files, STDOUT or STDERR
  - mongo - Logs to mongoDB

**Gems required for mongoDB support**

  - mongo
  - bson
  - bson_ext

## Usage

**Tapsilog Server**
  
  The best way to run tapsilog is to write a config file and call:

    tapsilog -c /path/to/config_file.yml

**Sample Config**

    port: 19080
    host:
      - 127.0.0.1
    socket:
      - /tmp/tapsilog.sock
    daemonize: false
    key: some_serious_key

    syncinterval: 1

    logs:
      #Currently supports file or mongo
      adapter: mongo

      #These options are used for mongo backend.
      #You can leave the host, port, user and password blank and tapsilog connects to your local mongo installation by default
      
      #host: 127.0.0.1
      #port: 1234
      #user: root
      #password: somepassword
      database: tapsilog
      
      services:
        - service: default
          target: default # This is the mongodb namespace. For file backend, use the path of log file

        - service: dev.access
          target: dev.access

        - service: dev.bizsupport
          target: dev.bizsupport

**Tapsilog Client**

  The tapsilog Logger class quacks like the ruby standard Logger.

**Sample**

    logger = Palmade::Tapsilog::Logger.new('default', '/tmp/tapsilog.sock', 'some_serious_key')
    logger.level = Palmade::Tapsilog::Logger::DEBUG # defaults to INFO
    logger.info("I am logging a message.", {:my_name => "tapsilog", :my_number => 2})

