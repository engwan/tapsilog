require 'socket'
require 'eventmachine'

module Palmade
  module Tapsilog

    autoload :Protocol, File.join(File.dirname(__FILE__), 'tapsilog/protocol')
    autoload :Server, File.join(File.dirname(__FILE__), 'tapsilog/server')

  end
end
