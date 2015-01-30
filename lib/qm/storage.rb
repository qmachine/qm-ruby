#-  Ruby source code

#-  storage.rb ~~
#                                                       ~~ (c) SRW, 27 Jan 2015
#                                                   ~~ last updated 29 Jan 2015

require 'qm/defs-mongo'
require 'sinatra/base'

module QM

    class Storage

        def close()
          # This method needs documentation.
            if (@settings.persistent_storage.has_key?(:mongo)) then
                MongoStorage.close
            end
            if (@settings.trafficlog_storage.has_key?(:mongo)) then
                MongoStorage.close
            end
        end

        def connect_api_store()
          # This method needs documentation.
            if (@settings.persistent_storage.has_key?(:mongo)) then
                MongoStorage.connect_api_store(@settings)
            end
        end

        def connect_log_store()
          # This method needs documentation.
            if (@settings.trafficlog_storage.has_key?(:mongo)) then
                MongoStorage.connect_log_store(@settings)
            end
        end

        def get_avar(params)
          # This method needs documentation.
            if (@settings.persistent_storage.has_key?(:mongo)) then
                return MongoStorage.get_avar(params)
            end
        end

        def get_list(params)
          # This method needs documentation.
            if (@settings.persistent_storage.has_key?(:mongo)) then
                return MongoStorage.get_list(params)
            end
        end

        def initialize(settings = {})
          # This is the constructor.
            @settings = settings
        end

        def log(request)
          # This method needs documentation.
            if (@settings.trafficlog_storage.has_key?(:mongo)) then
                return MongoStorage.log(request)
            end
        end

        def set_avar(params)
          # This method needs documentation.
            if (@settings.persistent_storage.has_key?(:mongo)) then
                return MongoStorage.set_avar(params)
            end
        end

    end

    module StorageConnector

        def connect_api_store(opts = settings)
          # This function needs documentation.
            @db ||= Storage.new(opts)
            return @db if @db.connect_api_store
        end

        def connect_log_store(opts = settings)
          # This function needs documentation.
            @db ||= Storage.new(opts)
            return @db if @db.connect_log_store
        end

    end

    Sinatra.register StorageConnector

end

#-  vim:set syntax=ruby:
