#-  Ruby source code

#-  defs-sqlite.rb ~~
#                                                       ~~ (c) SRW, 16 Jul 2014
#                                                   ~~ last updated 30 Jan 2015

module QM

    class SqliteApiStore

        def close()
          # This method isn't meaningful for the current implementation because
          # the `execute` method opens and closes the SQLite database file for
          # each and every request. If you want high performance, do *NOT* use
          # SQLite as storage for QM :-P
            return
        end

        def connect(opts = {})
          # This method needs documentation.
            @db ||= opts[:sqlite] if opts.has_key?(:sqlite)
            return @db
        end

        def execute(query)
          # This helper method helps DRY out the code for database queries, and
          # it does so in an incredibly robust and inefficient way -- by
          # creating the table and evicting expired rows before every single
          # query. A caveat, of course, is that the special ":memory:" database
          # doesn't work correctly, but ":memory:" isn't *persistent* storage
          # anyway.
            begin
                db = SQLite3::Database.open(@db)
                now = (1000 * Time.now.to_f).to_i
                db.execute_batch <<-sql
                    CREATE TABLE IF NOT EXISTS avars (
                        body TEXT NOT NULL,
                        box TEXT NOT NULL,
                        exp_date INTEGER NOT NULL,
                        key TEXT NOT NULL,
                        status TEXT,
                        PRIMARY KEY (box, key)
                    );
                    DELETE FROM avars WHERE (exp_date < #{now})
                    sql
              # We have to execute the query code `query` separately because
              # the `db.execute_batch` function always returns `nil`, which
              # prevents us from being able to retrieve the results of the
              # query.
                x = db.execute(query)
            rescue SQLite3::Exception => err
                STDERR.puts "Exception occurred: #{err} (#{query})"
            ensure
                db.close if db
            end
            return x
        end

        def get_avar(params)
          # This method needs documentation.
            exp_date = (1000 * (Time.now.to_f + @settings.avar_ttl)).to_i
            x = execute <<-sql
                SELECT body FROM avars
                WHERE box = '#{params[0]}' AND key = '#{params[1]}'
                sql
            if x.length == 0 then
                y = '{}'
            else
                execute <<-sql
                    UPDATE avars SET exp_date = #{exp_date}
                    WHERE box = '#{params[0]}' and key = '#{params[1]}'
                    sql
                y = x[0][0]
            end
            return y
        end

        def get_list(params)
          # This method needs documentation.
            b, now, s = params[0], (1000 * Time.now.to_f).to_i, params[1]
            x = execute <<-sql
                SELECT key FROM avars
                WHERE box = '#{b}' AND exp_date > #{now} AND status = '#{s}'
                sql
            return (x.length == 0) ? '[]' : (x.map {|row| row[0]}).to_json
        end

        def initialize(opts = {})
          # This constructor needs documentation.
            require 'json'
            require 'sqlite3'
            @settings = opts
        end

        def set_avar(params)
          # This method needs documentation.
            body, box, key = params.last, params[0], params[1]
            ed = (1000 * (Time.now.to_f + @settings.avar_ttl)).to_i
            if (params.length == 4) then
              # This arm runs only when a client writes an avar that represents
              # a task description.
                status = params[2]
                execute <<-sql
                    INSERT OR REPLACE INTO avars
                        (body, box, exp_date, key, status)
                    VALUES ('#{body}', '#{box}', #{ed}, '#{key}', '#{status}')
                    sql
            else
              # This arm runs when a client is writing a "regular avar".
                execute <<-sql
                    INSERT OR REPLACE INTO avars (body, box, exp_date, key)
                    VALUES ('#{body}', '#{box}', #{ed}, '#{key}')
                    sql
            end
        end

    end

  # NOTE: There is no `SqliteLogStore` class.

end

#-  vim:set syntax=ruby:
