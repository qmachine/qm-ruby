#-  Ruby source code

#-  client.rb ~~
#
#   This file is a simple placeholder at the moment. My idea is to embed one JS
#   execution context in each `QMachineClient` object and then to load the
#   latest browser client inside. Obviously, that won't coordinate *arbitrary*
#   code -- or even Ruby code -- but it will save me from rewriting a client
#   completely from scratch because it is possible to add functions and objects
#   to the JS context which are implemented in Ruby. Thus, instead of writing
#   a client in Ruby that will act like the browser client, the idea is to
#   make Ruby act like a browser so I can reuse the browser client :-)
#
#                                                       ~~ (c) SRW, 20 Jul 2014
#                                                   ~~ last updated 21 Jul 2014

require 'httparty'
require 'v8'

class QMachineClient

    include HTTParty

    def initialize(options = {})
      # This method runs when Ruby calls `QMachineClient.new`.
        @@ctx = V8::Context.new
        puts '(placeholder: `QM::launch_client`)'
    end

end

#-  vim:set syntax=ruby:
