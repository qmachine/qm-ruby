#-  Ruby source code

#-  storage.rb ~~
#
#   See http://www.sinatrarb.com/extensions.html.
#
#                                                       ~~ (c) SRW, 27 Jan 2015
#                                                   ~~ last updated 29 Jan 2015

require 'qm/defs-mongo'
require 'sinatra/base'

module QM

    module StorageConnectors

      # These functions extend Sinatra's DSL (class) context.

        def connect_api_store(opts = settings.persistent_storage)
          # This function needs documentation.
            if (opts.has_key?(:mongo)) then
                return MongoConnectors.send(:connect_api_store, opts)
            end
        end

        def connect_log_store(opts = settings.trafficlog_storage)
          # This function needs documentation.
            if (opts.has_key?(:mongo)) then
                return MongoConnectors.send(:connect_log_store, opts)
            end
        end

    end

    module StorageHelpers

      # These function extend Sinatra's Request context.

        include MongoHelpers

    end

    Sinatra.helpers StorageHelpers
    Sinatra.register StorageConnectors

end

#-  vim:set syntax=ruby:
