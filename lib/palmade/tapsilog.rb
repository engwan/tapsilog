require 'eventmachine'

module Palmade
  module Tapsilog

    autoload :Server, File.join(File.dirname(__FILE__), 'tapsilog/server')

  end
end
