require 'socket'
require 'timeout'
require 'eventmachine'

module Palmade
  module Tapsilog
    class Timeout < Exception; end

    autoload :Protocol, File.join(File.dirname(__FILE__), 'tapsilog/protocol')
    autoload :Server, File.join(File.dirname(__FILE__), 'tapsilog/server')
    autoload :Adapters, File.join(File.dirname(__FILE__), 'tapsilog/adapters')
    autoload :Utils, File.join(File.dirname(__FILE__), 'tapsilog/utils')

    autoload :Conn, File.join(File.dirname(__FILE__), 'tapsilog/conn')
    autoload :Client, File.join(File.dirname(__FILE__), 'tapsilog/client')
    autoload :Logger, File.join(File.dirname(__FILE__), 'tapsilog/logger')

  end
end
