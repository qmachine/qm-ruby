#-  Ruby source code

#-  defs-mongo.rb ~~
#                                                       ~~ (c) SRW, 16 Jul 2014
#                                                   ~~ last updated 31 Jan 2015

require 'json'
require 'mongo'

module QM

    class MongoApiStore

        def close()
          # This method documentation.
            @db.connection.close if @db.respond_to?('connection')
            return
        end

        def connect(opts = {})
          # This method needs documentation.
            if opts.has_key?(:mongo) then
                @db ||= Mongo::MongoClient.from_uri(opts[:mongo]).db
                @db.collection('avars').ensure_index({
                    box: Mongo::ASCENDING,
                    key: Mongo::ASCENDING
                }, {
                    unique: true
                })
                @db.collection('avars').ensure_index('exp_date', {
                    expireAfterSeconds: 0
                })
                STDOUT.puts 'API: MongoDB storage is ready.'
            end
            return @db
        end

        def get_avar(params)
          # This method retrieves an avar's representation if it exists, and it
          # also updates the "expiration date" of the avar in the database so
          # that data still being used for computations will not be removed.
            x = @db.collection('avars').find_and_modify({
                fields: {
                    _id: 0,
                    body: 1
                },
                query: {
                    box: params[0],
                    exp_date: {
                        '$gt': Time.now
                    },
                    key: params[1]
                },
                update: {
                  # NOTE: The hash below must use `=>` (not `:`) in JRuby, as
                  # of version 1.7.18, but QM won't be supporting JRuby anyway
                  # until (a.) JRuby 9000 is stable and (b.) I understand Puma.
                    '$set': {
                        exp_date: Time.now + @settings.avar_ttl
                    }
                },
                upsert: false
            })
            return (x.nil?) ? '{}' : x['body']
        end

        def get_list(params)
          # This method retrieves a list of "key" properties for avars in the
          # database that have a "status" property, because those are assumed
          # to represent task descriptions. The function returns the list as a
          # stringified JSON array in which order is not important.
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
            @db.collection('avars').find(query, opts).each do |doc|
              # This block appends each task's key to a running list, but the
              # the order in which the keys are added is *not* sorted.
                x.push(doc['key'])
            end
            return (x.length == 0) ? '[]' : x.to_json
        end

        def initialize(opts = {})
          # This constructor needs documentation.
            @settings = opts
        end

        def set_avar(params)
          # This method writes an avar to the database by "upserting" a Mongo
          # document that represents it.
            doc = {
                body: params.last,
                box: params[0],
                exp_date: Time.now + @settings.avar_ttl,
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
            @db.collection('avars').update(query, doc, opts)
            return
        end

    end

    class MongoLogStore

        def close()
          # This method needs documentation.
            @db.connection.close if @db.respond_to?('connection')
            return
        end

        def connect(opts = {})
          # This method needs documentation.
            if (opts.has_key?(:mongo)) then
                @db ||= Mongo::MongoClient.from_uri(opts[:mongo]).db
                STDOUT.puts 'LOG: MongoDB storage is ready.'
            end
            return @db
        end

        def initialize(opts = {})
          # This constructor needs documentation.
            @settings = opts
        end

        def log(request)
          # This method inserts a new document into MongoDB after each request.
          # Eventually, this function will be replaced by one that delegates to
          # a custom `log` function like the Node.js version.
            @db.collection('traffic').insert({
                host:           request.host,
                method:         request.request_method,
                timestamp:      Time.now,
                url:            request.fullpath
            }, {
                w: 0
            })
            return
        end

    end

end

#-  vim:set syntax=ruby:
