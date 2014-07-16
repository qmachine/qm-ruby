#-  Ruby source code

#-  qm.rb ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 15 Jul 2014

module QM

    def self::launch_client(options = {})
      # This function needs documentation.
        puts '(placeholder: `launch_client`)'
        return
    end

    def self::launch_service(options = {})
      # This function creates, configures, and launches a fresh Sinatra app
      # that inherits from the original "teaching version".
        require 'server.rb'
        app = Sinatra.new(QMachineServer) { configure { set options } }
        return app.run!
    end

end

#-  vim:set syntax=ruby:
