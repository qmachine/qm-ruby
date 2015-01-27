#-  Ruby source code

#-  qm.rb ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 27 Jan 2015

module QM

    VERSION = '1.2.3'

  module_function

    def create_app(options = {})
      # This function creates and configures a fresh app. This code is separate
      # from the `launch_service` method's code to allow direct use of a
      # `QMachineService` instance from within a Rackup file ("config.ru").
        require 'qm/service'
        app = QMachineService.new
        convert = lambda do |x|
          # This converts all keys in a hash to symbols recursively.
            if x.is_a?(Hash) then
                x = x.inject({}) {|y, (k, v)| y[k.to_sym] = convert.call(v); y}
            end
            return x
        end
        app.settings.set(convert.call(options))
        app.settings.set({
          # Explicitly evaluate the lambdas in `QMachineService` and store the
          # outputs. This avoids re-evaluating them for every HTTP request
          # later, of course, but the main motivation is to avoid the MongoDB
          # connection bloat problem.
            api_db:     app.settings.api_db,
            bind:       app.settings.bind,
            log_db:     app.settings.log_db,
            logging:    app.settings.logging,
            static:     app.settings.static
        })
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
                if (server.app.settings.api_db.respond_to?('connection')) then
                    server.app.settings.api_db.connection.close
                end
                if (server.app.settings.log_db.respond_to?('connection')) then
                    server.app.settings.log_db.connection.close
                end
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
