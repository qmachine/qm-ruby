#-  Ruby source code

#-  storage.rb ~~
#
#   See http://www.sinatrarb.com/extensions.html.
#
#                                                       ~~ (c) SRW, 27 Jan 2015
#                                                   ~~ last updated 27 Jan 2015

require 'qm/defs-mongo'
require 'sinatra/base'

module QM

    module StorageConnectors

      # These functions extend Sinatra's DSL (class) context.

        include MongoConnectors

    end

    module StorageHelpers

      # These function extend Sinatra's Request context.

        include MongoHelpers

    end

    Sinatra.helpers StorageHelpers
    Sinatra.register StorageConnectors

end

#-  vim:set syntax=ruby:
