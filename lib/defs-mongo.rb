#-  Ruby source code

#-  defs-mongo.rb ~~
#                                                       ~~ (c) SRW, 16 Jul 2014
#                                                   ~~ last updated 17 Jul 2014

require 'bson'
require 'json'
require 'mongo'
require 'sinatra/base'
require 'uri'

module Sinatra

    module MongoConnect

        def mongo_connect()
          # This function needs documentation.
            db = URI.parse(settings.persistent_storage[:mongo])
            db_name = db.path.gsub(/^\//, '')
            conn = Mongo::Connection.new(db.host, db.port).db(db_name)
            unless db.user.nil? or db.password.nil?
                conn.authenticate(db.user, db.password)
            end
            set db: conn
            #settings.db = conn
            settings.db['avars'].ensure_index('exp_date', {
                expireAfterSeconds: settings.avar_ttl
            })
            return
        end

    end

    module MongoDefs

        def get_avar(params)
          # This helper function needs documentation.
            bk, db = "#{params[0]}&#{params[1]}", settings.db
            x = db['avars'].find_one({_id: bk})
            y = (x.nil?) ? '{}' : x['body']
            return y
        end

        def get_list(params)
          # This helper function needs documentation.
            bs, db, x = "#{params[0]}&#{params[1]}", settings.db, []
            db['avars'].find({box_status: bs}).each do |doc|
              # This block needs documentation.
                x.push(doc['key'])
            end
            y = (x.length == 0) ? '[]' : x.to_json
            return y
        end

        def set_avar(params)
          # This helper function needs documentation.
            db = settings.db
            doc = {
                _id: "#{params[0]}&#{params[1]}",
                body: params[2],
                exp_date: Time.now,
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

    helpers MongoDefs
    register MongoConnect

end

#-  vim:set syntax=ruby:
