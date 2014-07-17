#-  Ruby source code

#-  qm.rb ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 16 Jul 2014

module QM

    def self::launch_client(options = {})
      # This function needs documentation.
        puts '(placeholder: `launch_client`)'
        return
    end

    def self::launch_service(options = {})
      # This function creates, configures, and launches a fresh Sinatra app
      # that inherits from the original "teaching version".
        require 'service.rb'
        app = Sinatra.new(QMachineService) do
            configure do
                set options
                set bind: :hostname, run: false, static: :enable_web_server
            end
        end
        return app.run!
    end

end

#-  vim:set syntax=ruby:
