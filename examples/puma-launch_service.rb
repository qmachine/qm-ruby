#-  Ruby source code

#-  puma-launch_service.rb ~~
#                                                       ~~ (c) SRW, 26 Jan 2015
#                                                   ~~ last updated 05 Feb 2015

module QM

    def launch_service(options = {})
      # This function launches a new app using Puma. I would prefer to use Puma
      # instead of Unicorn in the future, in order to support as many of the
      # different Ruby platforms as possible, but that's not the main priority
      # for this "teaching version" anyway. Puma will teach *me* a lot about
      # concurrency in the meantime :-)
        require 'puma'
        app = create_app(options)
        server = Puma::Server.new(app)
        server.add_tcp_listener(app.settings.hostname, app.settings.port)
        server.min_threads = 1
        server.max_threads = 5 * app.settings.worker_procs.to_s.to_i(10)
        puts "QM up -> http://#{app.settings.hostname}:#{app.settings.port} ..."
        server.run.join
        return
    end

    module_function :launch_service

end

#-  vim:set syntax=ruby:
