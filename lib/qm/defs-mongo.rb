#-  Ruby source code

#-  defs-mongo.rb ~~
#
#   See http://www.sinatrarb.com/extensions.html.
#
#                                                       ~~ (c) SRW, 16 Jul 2014
#                                                   ~~ last updated 27 Jan 2015

require 'json'
require 'mongo'

module QM

    module MongoConnectors

      # These functions extend Sinatra's DSL (class) context.

        def connect_api_store(opts = settings.persistent_storage)
          # This function needs documentation.
            db = Mongo::MongoClient.from_uri(opts[:mongo]).db
            db.collection('avars').ensure_index({
                box: Mongo::ASCENDING,
                key: Mongo::ASCENDING
            }, {
                unique: true
            })
            db.collection('avars').ensure_index('exp_date', {
                expireAfterSeconds: 0
            })
            return db
        end

        def connect_log_store(opts = settings.trafficlog_storage)
          # This function needs documentation.
            if opts.has_key?(:mongo) then
                return Mongo::MongoClient.from_uri(opts[:mongo]).db
            end
        end

    end

    module MongoHelpers

      # These function extend Sinatra's Request context.

        def get_avar(params)
          # This helper function retrieves an avar's representation if it
          # exists, and it also updates the "expiration date" of the avar in
          # the database so that data still being used for computations will
          # not be removed.
            x = settings.api_db.collection('avars').find_and_modify({
                fields: {
                    _id: 0,
                    body: 1
                },
                query: {
                    box: params[0],
                    key: params[1]
                },
                update: {
                  # NOTE: The hash below must use `=>` (not `:`) in JRuby, as
                  # of version 1.7.18, but QM won't be supporting JRuby anyway
                  # until (a.) JRuby 9000 is stable and (b.) I understand Puma.
                    '$set': {
                        exp_date: Time.now + settings.avar_ttl
                    }
                },
                upsert: false
            })
            return (x.nil?) ? '{}' : x['body']
        end

        def get_list(params)
          # This helper function retrieves a list of "key" properties for avars
          # in the database that have a "status" property, because those are
          # assumed to represent task descriptions. The function returns the
          # list as a stringified JSON array in which order is not important.
            opts = {
                fields: {
                    _id: 0,
                    key: 1
                }
            }
            query = {
                box: params[0],
                exp_date: {
                    '$gt': Time.now
                },
                status: params[1]
            }
            x = []
            settings.api_db.collection('avars').find(query, opts).each do |doc|
              # This block appends each task's key to a running list, but the
              # the order in which the keys are added is *not* sorted.
                x.push(doc['key'])
            end
            return (x.length == 0) ? '[]' : x.to_json
        end

        def log_to_db()
          # This helper function inserts a new document into MongoDB after each
          # request. Eventually, this function will be replaced by one that
          # delegates to a custom `log` function like the Node.js version.
            settings.log_db.collection('traffic').insert({
                host:           request.host,
                method:         request.request_method,
                timestamp:      Time.now,
                url:            request.fullpath
            }, {
                w: 0
            })
            return
        end

        def set_avar(params)
          # This helper function writes an avar to the database by "upserting"
          # a Mongo document that represents it.
            doc = {
                body: params.last,
                box: params[0],
                exp_date: Time.now + settings.avar_ttl,
                key: params[1]
            }
            doc['status'] = params[2] if params.length == 4
            opts = {
                multi: false,
                upsert: true,
                w: 1
            }
            query = {
                box: params[0],
                key: params[1]
            }
            settings.api_db.collection('avars').update(query, doc, opts)
            return
        end

    end

end

#-  vim:set syntax=ruby:
