#-  Ruby source code

#-  defs-sqlite.rb ~~
#                                                       ~~ (c) SRW, 16 Jul 2014
#                                                   ~~ last updated 04 Feb 2015

require 'json'
require 'sqlite3'

module QM

    class SqliteApiStore

        def close()
          # This method isn't meaningful for the current implementation because
          # the `execute` method opens and closes the SQLite database file for
          # each and every request.
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

        def get_avar(params)
          # This method needs documentation.
            collect_garbage
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
            collect_garbage
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

        def set_avar(params)
          # This method needs documentation.
            collect_garbage
            body, box, key = params.last, params[0], params[1]
            status = (params.length == 4) ? "'#{params[2]}'" : 'NULL'
            execute <<-sql
                INSERT OR REPLACE INTO avars (body, box, exp_date, key, status)
                VALUES ('#{body}', '#{box}', #{exp_date}, '#{key}', #{status})
                sql
            return
        end

        private

        def collect_garbage()
          # This method needs documentation.
            return if defined?(@last_gc_date) and
                    ((Time.now - @last_gc_date) < @settings.gc_interval)
            @last_gc_date = Time.now
            execute("DELETE FROM avars WHERE (exp_date < #{now})")
            STDOUT.puts 'Finished collecting garbage.'
            return
        end

        def execute(query)
          # This helper method helps DRY out the code for database queries. The
          # `SQLite3::BusyException` is raised so often that the cleanest
          # solution is to loop until the query succeeds. The reason it occurs
          # so frequently is because SQLite uses file-level locking, and thus
          # it is not actually a good choice for an application like QMachine
          # with such a high frequency of reads and writes.
            done = false
            until (done == true) do
                begin
                    db = SQLite3::Database.open(@filename)
                    x = db.execute(query)
                    done = true
                rescue SQLite3::BusyException
                  # Do nothing here, because we *expect* this to happen a lot,
                  # especially as the number of `worker_procs` increases.
                rescue SQLite3::Exception => err
                  # Print unexpected errors to stderr, but don't halt the loop.
                  # We will just hope that the errors are temporary, because if
                  # they aren't, the code will be stuck in an infinite loop :-(
                    STDERR.puts "Exception occurred: '#{err}':\n#{query}"
                ensure
                    db.close if db
                end
            end
            return x
        end

        def exp_date()
          # This method needs documentation.
            return now + @settings.avar_ttl.to_i
        end

        def now()
          # This method needs documentation.
            return Time.now.to_i
        end

    end

  # NOTE: There is no `SqliteLogStore` class.

end

#-  vim:set syntax=ruby:
