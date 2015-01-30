#-  Ruby source code

#-  qm.rb ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 29 Jan 2015

module QM

    VERSION = '1.2.4'

  module_function

    def create_app(options = {})
      # This function creates and configures a fresh app. This code is separate
      # from the `launch_service` method's code to allow direct use of a
      # `QMachineService` instance from within a Rackup file ("config.ru").
        require 'qm/service'
        app = Sinatra.new(QMachineService) do
            configure do
                convert = lambda do |x|
                  # This converts all keys in a hash to symbols recursively.
                    if x.is_a?(Hash) then
                        x = x.inject({}) do |y, (key, val)|
                            y[key.to_sym] = convert.call(val); y
                        end
                    end
                    return x
                end
                convert.call(options).each_pair do |key, val|
                  # This provides feedback for user-specified options.
                    if settings.qm_options.include?(key) then
                        set(key, val)
                    else
                        STDERR.puts "Unknown option: #{key}"
                    end
                end
                settings.qm_lazy.each do |key|
                  # Eagerly evaluate the lambdas in `QMachineService` in the
                  # correct scope and store their outputs. This strategy avoids
                  # re-evaluating them for every HTTP request later, of course,
                  # but the main motivation is to avoid endlessly opening new
                  # connections without closing old ones.
                    set(key, settings.send(key))
                end
            end
        end
        return app
    end

    def launch_client(options = {mothership: 'https://api.qmachine.org'})
      # This function needs documentation.
        require 'qm/client'
        return QMachineClient.new(options)
    end

    def launch_service(options = {})
      # This function launches a new app using Unicorn :-)
        require 'unicorn'
        app = create_app(options)
        Unicorn::HttpServer.new(app, {
            before_fork: lambda {|server, worker|
              # This needs documentation.
                settings = server.app.settings
                settings.api_db.close if not settings.api_db.nil?
                settings.log_db.close if not settings.log_db.nil?
            },
            listeners: [
                app.settings.hostname.to_s + ':' + app.settings.port.to_s
            ],
            preload_app: true,
            timeout: 30,
            worker_processes: app.settings.worker_procs.to_s.to_i(10)
        }).start.join
        return
    end

    def version()
      # This function exists because it exists in the Node.js version.
        return VERSION
    end

end

#-  vim:set syntax=ruby:
