#-  Ruby source code

#-  defs-sqlite.rb ~~
#                                                       ~~ (c) SRW, 16 Jul 2014
#                                                   ~~ last updated 17 Jul 2014

require 'json'
require 'sinatra/base'
require 'sqlite3'

module Sinatra

    module SQLiteConnect

        def sqlite_connect()
          # This helper function doesn't do anything yet ...
            return
        end

    end

    module SQLiteDefs

        def get_avar(params)
          # This method needs documentation.
            bk = "#{params[0]}&#{params[1]}"
            x = sqlite("SELECT body FROM avars WHERE box_key = '#{bk}'")
            y = (x.length == 0) ? '{}' : x[0][0]
            return y
        end

        def get_list(params)
          # This method needs documentation.
            bs = "#{params[0]}&#{params[1]}"
            x = sqlite("SELECT key FROM avars WHERE box_status = '#{bs}'")
            y = (x.length == 0) ? '[]' : (x.map {|row| row[0]}).to_json
            return y
        end

        def now_plus(dt)
          # This helper method computes a date (in milliseconds) that is
          # specified by an offset `dt` (in seconds).
            return (1000 * (Time.now.to_f + dt)).to_i
        end

        def set_avar(params) 
          # This method needs documentation.
            if (params.length == 4) then
              # This arm runs only when a client writes an avar that represents
              # a task description.
                box, key, status = params[0], params[1], params[2]
                body, ed = params[3], now_plus(settings.avar_ttl)
                bk, bs = "#{@box}&#{@key}", "#{@box}&#{status}"
                sqlite("INSERT OR REPLACE INTO avars
                            (body, box_key, box_status, exp_date, key)
                        VALUES ('#{body}', '#{bk}', '#{bs}', #{ed}, '#{key}')")
            else
              # This arm runs when a client is writing a "regular avar".
                box, key, body = params[0], params[1], params[2]
                bk, ed = "#{box}&#{key}", now_plus(settings.avar_ttl)
                sqlite("INSERT OR REPLACE INTO avars (body, box_key, exp_date)
                        VALUES ('#{body}', '#{bk}', #{ed})")
            end
        end

        def sqlite(query)
          # This helper method helps DRY out the code for database queries, and
          # it does so in an incredibly robust and inefficient way -- by
          # creating the table and evicting expired rows before every single
          # query. A caveat, of course, is that the special ":memory:" database
          # doesn't work correctly, but ":memory:" isn't *persistent* storage
          # anyway. Also, I have omitted indexing on `box_status` for obvious
          # reasons :-P
            begin
                filename = settings.persistent_storage[:sqlite]
                db = SQLite3::Database.open(filename)
                db.execute_batch <<-sql
                    CREATE TABLE IF NOT EXISTS avars (
                        body TEXT NOT NULL,
                        box_key TEXT NOT NULL PRIMARY KEY,
                        box_status TEXT,
                        exp_date INTEGER NOT NULL,
                        key TEXT
                    );
                    DELETE FROM avars WHERE (exp_date < #{now_plus(0)})
                    sql
              # We have to execute the query code `query` separately because
              # the `db.execute_batch` function always returns `nil`, which
              # prevents us from being able to retrieve the results of the
              # query.
                x = db.execute(query)
            rescue SQLite3::Exception => err
                puts "Exception occurred: #{err}"
            ensure
                db.close if db
            end
            return x
        end

    end

    helpers SQLiteDefs
    register SQLiteConnect

end

#-  vim:set syntax=ruby:
