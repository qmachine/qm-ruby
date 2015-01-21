#-  Ruby source code

#-  qm.rb ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 20 Jan 2015

module QM

    def self::launch_client(options = {mothership: 'https://api.qmachine.org'})
      # This function needs documentation.
        require 'client'
        return QMachineClient.new(options)
    end

    def self::launch_service(options = {})
      # This function creates, configures, and launches a fresh Sinatra app
      # that inherits from the original "teaching version".
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
        return app.run!
    end

end

#-  vim:set syntax=ruby:
