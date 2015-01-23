#-  Ruby source code

#-  qm.rb ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 23 Jan 2015

module QM

    def self::create_app(options = {})
      # This function creates and configures a fresh Sinatra app that inherits
      # from the original "teaching version". This code is separated from the
      # `launch_service` method's code to allow a `QMachineService` instance to
      # be used from the "config.ru" file of a Rack app.
        require 'qm/service'
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
        require 'qm/client'
        return QMachineClient.new(options)
    end

    def self::launch_service(options = {})
      # This function launches a new app using Unicorn :-)
        require 'unicorn'
        app = self::create_app(options)
        Unicorn::HttpServer.new(app, {
            listeners: [
                app.settings.hostname.to_s + ':' + app.settings.port.to_s
            ],
            preload_app: true,
            timeout: 30,
            worker_processes: app.settings.worker_procs.to_s.to_i(10)
        }).start.join
        return
    end

=begin
    def self::launch_service(options = {})
      # This function launches a new app using Puma. I would prefer to use Puma
      # instead of Unicorn in the future, in order to support as many of the
      # different Ruby platforms as possible, but that's not the main priority
      # for this "teaching version" anyway. Puma will teach *me* a lot about
      # concurrency in the meantime :-)
        require 'puma'
        app = self::create_app(options)
        server = Puma::Server.new(app)
        server.add_tcp_listener(app.settings.hostname, app.settings.port)
        server.min_threads = 1
        server.max_threads = 16
        puts "QM up -> http://#{app.settings.hostname}:#{app.settings.port} ..."
        server.run.join
        return
    end
=end

    def self::version()
      # This function exists because it exists in the Node.js version.
        return VERSION
    end

    VERSION = '1.2.3'

end

#-  vim:set syntax=ruby:
