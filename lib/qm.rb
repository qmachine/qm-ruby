#-  Ruby source code

#-  qm.rb ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 21 Jan 2015

module QM

    def self::create_app(options = {})
      # This method creates and configures a fresh Sinatra app that inherits
      # from the original "teaching version". This code is separated from the
      # `launch_service` method's code to allow a `QMachineService` instance to
      # be used from the "config.ru" file of a Rack app.
        require 'service'
        app = Sinatra.new(QMachineService) do
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
            end
        end
        return app
    end

    def self::launch_client(options = {mothership: 'https://api.qmachine.org'})
      # This function needs documentation.
        require 'client'
        return QMachineClient.new(options)
    end

    def self::launch_service(options = {})
      # This function creates, configures, and launches a fresh Sinatra app
      # that inherits from the original "teaching version". There is probably
      # a prettier way to do this, but this works fine for right now.
        require 'unicorn'
        app = self::create_app(options)
        Unicorn::HttpServer.new(app, {
            listeners: [
                app.settings.hostname.to_s + ':' + app.settings.port.to_s
            ],
            timeout: 30,
            worker_processes: app.settings.worker_procs
        }).start.join
        return
    end

end

#-  vim:set syntax=ruby:
