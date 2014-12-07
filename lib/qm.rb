#-  Ruby source code

#-  qm.rb ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 07 Dec 2014

module QM

    def self::launch_client(options = {mothership: 'https://api.qmachine.org'})
      # This function needs documentation.
        require 'client'
        return QMachineClient.new(options)
    end

    def self::launch_service(options = {})
      # This function creates, configures, and launches a fresh Sinatra app
      # that inherits from the original "teaching version".
        require 'defs-mongo'
        require 'service'
        app = Sinatra.new(QMachineService) do
            register Sinatra::MongoConnect
            configure do
                convert = lambda do |x|
                  # This converts all keys in a hash to symbols recursively.
                    if x.is_a?(Hash) then
                        x = x.inject({}) do |memo, (k, v)|
                            memo[k.to_sym] = convert.call(v)
                            memo
                        end
                    end
                    return x
                end
                options = convert.call(options)
                set options
                if settings.persistent_storage.has_key?(:mongo) then
                    helpers Sinatra::MongoAPIDefs
                    mongo_api_connect
                end
                if settings.trafficlog_storage.has_key?(:mongo) then
                    helpers Sinatra::MongoLogDefs
                    mongo_log_connect
                    after do
                        log_to_db unless response.status == 444
                    end
                end
            end
        end
        return app.run!
    end

end

#-  vim:set syntax=ruby:
