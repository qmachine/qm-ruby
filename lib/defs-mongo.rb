#-  Ruby source code

#-  defs-mongo.rb ~~
#                                                       ~~ (c) SRW, 16 Jul 2014
#                                                   ~~ last updated 22 Jan 2015

require 'json'
require 'mongo'
require 'sinatra/base'

module Sinatra

    module MongoConnect

        def connect_api_store(opts = settings.persistent_storage)
          # This helper function needs documentation.
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
          # This helper function needs documentation.
            if opts.has_key?(:mongo) then
                return Mongo::MongoClient.from_uri(opts[:mongo]).db
            end
        end

    end

    module MongoAPIDefs

        def get_avar(params)
          # This helper function needs documentation.
            x = settings.api_db.collection('avars').find_and_modify({
                query: {
                    box: params[0],
                    key: params[1]
                },
                update: {
                    '$set': {
                        exp_date: Time.now + settings.avar_ttl
                    }
                },
                fields: {
                    _id: 0,
                    body: 1
                },
                upsert: false
            })
            return (x.nil?) ? '{}' : x['body']
        end

        def get_list(params)
          # This helper function needs documentation.
            opts = {
                fields: {
                    _id: 0,
                    key: 1
                }
            }
            query = {
                box: params[0],
                status: params[1]
            }
            x = []
            settings.api_db.collection('avars').find(query, opts).each do |doc|
              # This block needs documentation.
                x.push(doc['key'])
            end
            return (x.length == 0) ? '[]' : x.to_json
        end

        def set_avar(params)
          # This helper function needs documentation.
            doc = {
                body: params.last,
                box: params[0],
                exp_date: Time.now + settings.avar_ttl,
                key: params[1]
            }
            doc['status'] = params[2] if params.length == 4
            opts = {
                multi: false,
                upsert: true
            }
            query = {
                box: params[0],
                key: params[1]
            }
            settings.api_db.collection('avars').update(query, doc, opts)
            return
        end

    end

    module MongoLogDefs

        def log_to_db()
          # This helper function needs documentation.
            settings.log_db.collection('traffic').insert({
                host:           request.host,
                ip:             request.ip,
                method:         request.request_method,
                status_code:    response.status,
                timestamp:      Time.now,
                url:            request.fullpath
            })
            return
        end

    end

    helpers MongoAPIDefs, MongoLogDefs
    register MongoConnect

end

#-  vim:set syntax=ruby:
