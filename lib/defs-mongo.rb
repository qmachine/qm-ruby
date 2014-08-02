#-  Ruby source code

#-  defs-mongo.rb ~~
#                                                       ~~ (c) SRW, 16 Jul 2014
#                                                   ~~ last updated 02 Aug 2014

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
            settings.api_db['avars'].ensure_index('box_status', {
                background: true,
                sparse: true
            })
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
            bk, db = "#{params[0]}&#{params[1]}", settings.api_db
            x = db['avars'].find_and_modify({
                query: {_id: "#{params[0]}&#{params[1]}"},
                update: {'$set': {exp_date: Time.now + settings.avar_ttl}},
                fields: {body: 1}
            })
            y = (x.nil?) ? '{}' : x['body']
            return y
        end

        def get_list(params)
          # This helper function needs documentation.
            bs, db, x = "#{params[0]}&#{params[1]}", settings.api_db, []
            db['avars'].find({box_status: bs}).each do |doc|
              # This block needs documentation.
                x.push(doc['key'])
            end
            y = (x.length == 0) ? '[]' : x.to_json
            return y
        end

        def set_avar(params)
          # This helper function needs documentation.
            db = settings.api_db
            doc = {
                _id: "#{params[0]}&#{params[1]}",
                body: params[2],
                exp_date: Time.now + settings.avar_ttl,
                key: params[1]
            }
            options = {upsert: true}#, w: 1}
            if (params.length == 4) then
                doc['body'] = params[3]
                doc['box_status'] = "#{params[0]}&#{params[2]}"
            end
            db['avars'].update({_id: doc[:_id]}, doc, options)
            return
        end

    end

    module MongoLogDefs

        def log_to_db()
          # This method needs documentation.
            settings.log_db['traffic'].insert({
                host:   request.host,
                ip:     request.ip,
                method: request.request_method,
                timestamp: Time.now,
                #status: response.status,
                url:    request.fullpath
            })
            return
        end

    end

    helpers MongoAPIDefs, MongoLogDefs
    register MongoConnect

end

#-  vim:set syntax=ruby:
