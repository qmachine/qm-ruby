#-  Ruby source code

#-  defs-mongo.rb ~~
#                                                       ~~ (c) SRW, 16 Jul 2014
#                                                   ~~ last updated 14 Jan 2015

require 'json'
require 'mongo'
require 'sinatra/base'
require 'uri'

module Sinatra

    module MongoConnect

        def mongo_api_connect()
          # This function needs documentation.
            db = URI.parse(settings.persistent_storage[:mongo])
            db_name = db.path.gsub(/^\//, '')
            conn = Mongo::Connection.new(db.host, db.port).db(db_name)
            unless db.user.nil? or db.password.nil?
                conn.authenticate(db.user, db.password)
            end
            set api_db: conn
            settings.api_db['avars'].ensure_index({
                box: Mongo::ASCENDING,
                key: Mongo::ASCENDING
            }, {
                #background: true,
                unique: true
            })
          # This query covers the `get_list` query completely, but because an
          # index trades space for time, it needs to be profiled first to make
          # sure it's actually faster.
            #settings.api_db['avars'].ensure_index({
            #    box: Mongo::ASCENDING,
            #    key: Mongo::ASCENDING,
            #    status: Mongo::ASCENDING
            #})
            settings.api_db['avars'].ensure_index('exp_date', {
                expireAfterSeconds: 0
            })
            return
        end

        def mongo_log_connect()
          # This function needs documentation.
            db = URI.parse(settings.trafficlog_storage[:mongo])
            db_name = db.path.gsub(/^\//, '')
            conn = Mongo::Connection.new(db.host, db.port).db(db_name)
            unless db.user.nil? or db.password.nil?
                conn.authenticate(db.user, db.password)
            end
            set log_db: conn, logging: false
            return
        end

    end

    module MongoAPIDefs

        def get_avar(params)
          # This helper function needs documentation.
            x = settings.api_db['avars'].find_and_modify({
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
            options = {
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
            settings.api_db['avars'].find(query, options).each do |doc|
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
            options = {
                multi: false,
                upsert: true
            }
            query = {
                box: params[0],
                key: params[1]
            }
            settings.api_db['avars'].update(query, doc, options)
            return
        end

    end

    module MongoLogDefs

        def log_to_db()
          # This method needs documentation.
            settings.log_db['traffic'].insert({
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
