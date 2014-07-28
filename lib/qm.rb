#-  Ruby source code

#-  qm.rb ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 28 Jul 2014

module QM

    def self::launch_client(options = {})
      # This function needs documentation.
        require 'client.rb'
        return QMachineClient.new(options)
    end

    def self::launch_service(options = {})
      # This function creates, configures, and launches a fresh Sinatra app
      # that inherits from the original "teaching version".
        require 'service.rb'
        require 'defs-mongo'
        #require 'defs-sqlite'
        app = Sinatra.new(QMachineService) do
            register Sinatra::MongoConnect
            #register Sinatra::SQLiteConnect
            configure do
                convert = lambda do |x|
                  # This converts all keys in a hash to symbols recursively.
                    if (x.is_a?(Hash)) then
                        x = x.inject({}) do |memo, (k, v)|
                            memo[k.to_sym] = convert.call(v)
                            memo
                        end
                    end
                    return x
                end
                options = convert.call(options)
                set options
                set bind: :hostname, run: false, static: :enable_web_server
                if (settings.persistent_storage.has_key?(:mongo)) then
                    helpers Sinatra::MongoAPIDefs
                    mongo_api_connect
                #elsif (settings.persistent_storage.has_key?(:sqlite)) then
                #    helpers Sinatra::SQLiteDefs
                #    sqlite_connect
                end
                if (settings.trafficlog_storage.has_key?(:mongo)) then
                    helpers Sinatra::MongoLogDefs
                    mongo_log_connect
                    after do
                        log_to_db
                    end
                end
            end
        end
        return app.run!
    end

end

#-  vim:set syntax=ruby:
