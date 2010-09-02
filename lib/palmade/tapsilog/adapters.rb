module Palmade::Tapsilog
  module Adapters

    autoload :BaseAdapter, File.join(File.dirname(__FILE__), 'adapters/base_adapter')
    autoload :FileAdapter, File.join(File.dirname(__FILE__), 'adapters/file_adapter')
    autoload :MongoAdapter, File.join(File.dirname(__FILE__), 'adapters/mongo_adapter')

  end
end
