#-  Ruby source code

#-  client.rb ~~
#
#   This file is a simple placeholder.
#
#                                                       ~~ (c) SRW, 20 Jul 2014
#                                                   ~~ last updated 20 Jul 2014

require 'httparty'

class QMachineClient

    include HTTParty

    def initialize(options = {})
      # This method runs when Ruby calls `QMachineClient.new`.
        puts '(placeholder: `QM::launch_client`)'
    end

end

#-  vim:set syntax=ruby:
