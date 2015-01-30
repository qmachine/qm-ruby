#-  Ruby source code

#-  storage.rb ~~
#                                                       ~~ (c) SRW, 27 Jan 2015
#                                                   ~~ last updated 29 Jan 2015

require 'qm/defs-mongo'
require 'sinatra/base'

module QM

    class ApiStore

        def initialize(opts = {})
          # This is the constructor.
            if (opts.persistent_storage.has_key?(:mongo)) then
                @db = MongoStore.new(opts)
            end
            @db.connect_api_store(opts.persistent_storage) if not @db.nil?
        end

        def method_missing(method, *args, &block)
          # This function needs documentation.
            return @db.send(method, *args, &block) if not @db.nil?
        end

    end

    class LogStore

        def initialize(opts = {})
          # This is the constructor.
            if (opts.trafficlog_storage.has_key?(:mongo)) then
                @db = MongoStore.new(opts)
            end
            @db.connect_log_store(opts.trafficlog_storage) if not @db.nil?
        end

        def method_missing(method, *args, &block)
          # This function needs documentation.
            return @db.send(method, *args, &block) if not @db.nil?
        end

    end

    module StorageConnectors

        def connect_api_store(opts = settings)
          # This function needs documentation.
            @api_db ||= ApiStore.new(opts)
            return @api_db if @api_db.connect_api_store
        end

        def connect_log_store(opts = settings)
          # This function needs documentation.
            @log_db ||= LogStore.new(opts)
            return @log_db if @log_db.connect_log_store
        end

    end

    Sinatra.register StorageConnectors

end

#-  vim:set syntax=ruby:
