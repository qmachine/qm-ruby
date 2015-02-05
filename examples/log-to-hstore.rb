#-  Ruby source code

#-  log-to-hstore.rb ~~
#
#   This file contains the old definitions for logging to Postgres via the
#   "hstore" extension.
#
#                                                       ~~ (c) SRW, 05 Feb 2015
#                                                   ~~ last updated 05 Feb 2015

require 'pg'
require 'pg_hstore'
require 'uri'

module QM

    class PostgresLogStore

        def connect(opts = {})
          # This method needs documentation.
            if opts.has_key?(:postgres) then
                parsed = URI.parse(opts[:postgres])
                temp = {
                    dbname: parsed.path.gsub('/', ''),
                    host: parsed.host,
                    port: parsed.port.to_i
                }
                temp[:user] = parsed.user unless parsed.user.nil?
                temp[:password] = parsed.password unless parsed.password.nil?
                @conn_opts ||= temp
                @db ||= PG::Connection.open(@conn_opts)
                execute <<-end
                    CREATE EXTENSION IF NOT EXISTS hstore;
                    CREATE TABLE IF NOT EXISTS traffic (
                        id serial PRIMARY KEY,
                        doc hstore
                    );
                end
                STDOUT.puts 'LOG: PostgreSQL storage is ready.'
            end
            return @db
        end

        def log(doc = {})
          # This method inserts a new entry into Postgres after each request.
            execute("INSERT INTO traffic (doc) VALUES (#{PgHstore.dump(doc)})")
            return
        end

    end

end

#-  vim:set syntax=ruby:
