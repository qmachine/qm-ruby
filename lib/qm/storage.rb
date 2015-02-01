#-  Ruby source code

#-  storage.rb ~~
#                                                       ~~ (c) SRW, 27 Jan 2015
#                                                   ~~ last updated 31 Jan 2015

require 'sinatra/base'

module QM

    class ApiStore

        def initialize(opts = {})
          # This is the constructor.
            if opts.persistent_storage.has_key?(:mongo) then
                require 'qm/defs-mongo'
                @db = MongoApiStore.new(opts)
            elsif opts.persistent_storage.has_key?(:postgres) then
                require 'qm/defs-postgres'
                @db = PostgresApiStore.new(opts)
            elsif opts.persistent_storage.has_key?(:sqlite) then
                require 'qm/defs-sqlite'
                @db = SqliteApiStore.new(opts)
            end
            @db.connect(opts.persistent_storage) if defined?(@db)
        end

        def method_missing(method, *args, &block)
          # This function needs documentation.
            return @db.send(method, *args, &block) if defined?(@db)
        end

    end

    class LogStore

        def initialize(opts = {})
          # This is the constructor.
            if opts.trafficlog_storage.has_key?(:mongo) then
                require 'qm/defs-mongo'
                @db = MongoLogStore.new(opts)
            end
            @db.connect(opts.trafficlog_storage) if defined?(@db)
        end

        def method_missing(method, *args, &block)
          # This function needs documentation.
            return @db.send(method, *args, &block) if defined?(@db)
        end

    end

    module StorageConnectors

        def connect_api_store(opts = settings)
          # This function needs documentation.
            @api_db ||= ApiStore.new(opts)
            return @api_db if @api_db.connect
        end

        def connect_log_store(opts = settings)
          # This function needs documentation.
            @log_db ||= LogStore.new(opts)
            return @log_db if @log_db.connect
        end

    end

    Sinatra.register StorageConnectors

end

#-  vim:set syntax=ruby:
