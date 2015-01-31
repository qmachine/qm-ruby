#-  Ruby source code

#-  defs-sqlite.rb ~~
#                                                       ~~ (c) SRW, 16 Jul 2014
#                                                   ~~ last updated 31 Jan 2015

require 'json'
require 'sqlite3'

module QM

    class SqliteApiStore

        def close()
          # This method isn't meaningful for the current implementation because
          # the `execute` method opens and closes the SQLite database file for
          # each and every request. If you want high performance, do *NOT* use
          # SQLite as storage for QMachine :-P
            return
        end

        def collect_garbage()
          # This method needs documentation.
            execute("DELETE FROM avars WHERE (exp_date < #{now})")
            return
        end

        def connect(opts = {})
          # This method needs documentation.
            if opts.has_key?(:sqlite) then
                @filename ||= opts[:sqlite]
                execute <<-sql
                    CREATE TABLE IF NOT EXISTS avars (
                        body TEXT NOT NULL,
                        box TEXT NOT NULL,
                        exp_date INTEGER NOT NULL,
                        key TEXT NOT NULL,
                        status TEXT,
                        PRIMARY KEY (box, key)
                    );
                    sql
                collect_garbage
            end
            return @filename
        end

        def execute(query)
          # This helper method helps DRY out the code for database queries.
            done = false
            until (done == true) do
                begin
                    db = SQLite3::Database.open(@filename)
                    x = db.execute(query)
                    done = true
                rescue SQLite3::Exception => err
                    if (err.is_a?(SQLite3::BusyException) == false) then
                        STDERR.puts "Exception occurred: '#{err}':\n#{query}"
                    end
                ensure
                    db.close if db
                end
            end
            return x
        end

        def exp_date()
          # This method needs documentation.
            return now + @settings.avar_ttl.to_i(10)
        end

        def get_avar(params)
          # This method needs documentation.
            box, key = params[0], params[1]
            x = execute <<-sql
                SELECT body FROM avars
                WHERE box = '#{box}' AND exp_date > #{now} AND key = '#{key}'
                sql
            if x.length == 0 then
                y = '{}'
            else
              # If a row was found, update its expiration date.
                y = x[0][0]
                x = execute <<-sql
                    UPDATE avars SET exp_date = #{exp_date}
                    WHERE box = '#{box}' and key = '#{key}'
                    sql
            end
            return y
        end

        def get_list(params)
          # This method needs documentation.
            b, s = params[0], params[1]
            x = execute <<-sql
                SELECT key FROM avars
                WHERE box = '#{b}' AND exp_date > #{now} AND status = '#{s}'
                sql
            return (x.length == 0) ? '[]' : (x.map {|row| row[0]}).to_json
        end

        def initialize(opts = {})
          # This constructor needs documentation.
            @settings = opts
        end

        def now()
          # This method needs documentation.
            return Time.now.to_i(10)
        end

        def set_avar(params)
          # This method needs documentation.
            body, box, key = params.last, params[0], params[1]
            status = (params.length == 4) ? "'#{params[2]}'" : 'NULL'
            execute <<-sql
                INSERT OR REPLACE INTO avars (body, box, exp_date, key, status)
                VALUES ('#{body}', '#{box}', #{exp_date}, '#{key}', #{status})
                sql
            collect_garbage
            return
        end

        private :collect_garbage, :execute, :exp_date, :now

    end

  # NOTE: There is no `SqliteLogStore` class.

end

#-  vim:set syntax=ruby:
