#-  Ruby source code

#-  qm.rb ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 13 Jul 2014

module QM

  private

    class QM_Client

        def initialize
          # This function needs documentation.
            # ...
        end

    end

  public

    def self::launch_client()
      # This function needs documentation.
        puts '(placeholder: `launch_client`)';
        return;
    end

    def self::launch_service(*obj)
      # This function needs documentation.
        require 'api-server.rb'
        #puts '(placeholder: `launch_service`)';
        return;
    end

end

#-  vim:set syntax=ruby:
