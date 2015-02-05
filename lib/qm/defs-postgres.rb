#-  Ruby source code

#-  defs-postgres.rb ~~
#                                                       ~~ (c) SRW, 31 Jan 2015
#                                                   ~~ last updated 04 Feb 2015

require 'json'
require 'pg'
require 'pg_hstore'
require 'uri'

module QM

    class PostgresApiStore

        def close()
          # This method documentation.
            begin
                @db.close if @db.respond_to?('close')
            rescue
            end
            return
        end

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
                    CREATE TABLE IF NOT EXISTS avars (
                        body TEXT NOT NULL,
                        box TEXT NOT NULL,
                        key TEXT NOT NULL,
                        last_touch TIMESTAMP NOT NULL DEFAULT NOW(),
                        status TEXT,
                        PRIMARY KEY (box, key)
                    );

                    CREATE OR REPLACE FUNCTION evict_old_avars()
                        RETURNS TRIGGER AS
                    $$
                    BEGIN
                        DELETE FROM avars
                        WHERE last_touch < NOW() - INTERVAL
                            '#{@settings.avar_ttl} seconds';
                        RETURN NEW;
                    END;
                    $$
                    language plpgsql;

                    DROP TRIGGER IF EXISTS avar_gc ON avars;

                    CREATE TRIGGER avar_gc
                        AFTER INSERT ON avars
                        EXECUTE PROCEDURE evict_old_avars();

                    CREATE OR REPLACE FUNCTION upsert_avar
                        (body2 TEXT, box2 TEXT, key2 TEXT) RETURNS VOID AS
                    $$
                    BEGIN
                        LOOP
                            UPDATE avars
                                SET body = body2,
                                    last_touch = NOW(),
                                    status = NULL
                                WHERE box = box2 AND key = key2;
                            IF found THEN
                                RETURN;
                            END IF;
                            BEGIN
                                INSERT INTO avars (body, box, key)
                                    VALUES (body2, box2, key2);
                                RETURN;
                            EXCEPTION WHEN unique_violation THEN
                            END;
                        END LOOP;
                    END;
                    $$
                    LANGUAGE plpgsql;

                    CREATE OR REPLACE FUNCTION upsert_task
                        (body2 TEXT, box2 TEXT, key2 TEXT, status2 TEXT)
                        RETURNS VOID AS
                    $$
                    BEGIN
                        LOOP
                            UPDATE avars
                                SET body = body2,
                                    last_touch = NOW(),
                                    status = status2
                                WHERE box = box2 AND key = key2;
                            IF found THEN
                                RETURN;
                            END IF;
                            BEGIN
                                INSERT INTO avars (body, box, key, status)
                                    VALUES (body2, box2, key2, status2);
                                RETURN;
                            EXCEPTION WHEN unique_violation THEN
                            END;
                        END LOOP;
                     END;
                     $$
                     LANGUAGE plpgsql;
                end
                STDOUT.puts 'API: PostgreSQL storage is ready.'
            end
            return @db
        end

        def get_avar(params)
          # This method needs documentation.
            avar_ttl = @settings.avar_ttl
            x = execute <<-end
                UPDATE avars
                    SET last_touch = NOW()
                    WHERE box = '#{params[0]}' AND key = '#{params[1]}' AND
                        last_touch > NOW() - INTERVAL '#{avar_ttl} seconds'
                    RETURNING body
            end
            return (x.cmdtuples == 0) ? '{}' : x[0]['body']
        end

        def get_list(params)
          # This method needs documentation.
            avar_ttl = @settings.avar_ttl
            x = execute <<-end
                SELECT key FROM avars
                    WHERE box = '#{params[0]}' AND status = '#{params[1]}' AND
                        last_touch > NOW() - INTERVAL '#{avar_ttl} seconds'
            end
            return (x.cmdtuples == 0) ? '[]' : (x.map {|x| x['key']}).to_json
        end

        def initialize(opts = {})
          # This constructor needs documentation.
            @settings = opts
        end

        def set_avar(params)
          # This method needs documentation.
            if (params.length == 3) then
                execute('SELECT upsert_avar($3, $1, $2)', params)
            else
                execute('SELECT upsert_task($4, $1, $2, $3)', params)
            end
            return
        end

        private

        def execute(query, x = [])
          # This method needs documentation.
            begin
                y = (x.length > 0) ? @db.exec_params(query, x) : @db.exec(query)
            rescue PG::ConnectionBad
              # This is expected to occur once per worker because of forking.
                STDERR.puts 'Reconnecting ...'
                @db = PG::Connection.open(@conn_opts)
                return execute(query, x)
            rescue PG::Error => err
                STDERR.puts "Exception occurred: '#{err}':\n#{query}"
            end
            return y
        end

    end

    class PostgresLogStore

        def close()
          # This method documentation.
            begin
                @db.close if @db.respond_to?('close')
            rescue
            end
            return
        end

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

        def initialize(opts = {})
          # This constructor needs documentation.
            @settings = opts
        end

        def log(doc = {})
          # This method inserts a new entry into Postgres after each request.
            execute("INSERT INTO traffic (doc) VALUES (#{PgHstore.dump(doc)})")
            return
        end

        private

        def execute(query)
          # This method needs documentation.
            begin
                y = @db.exec(query)
            rescue PG::ConnectionBad
              # This is expected to occur once per worker because of forking.
                STDERR.puts 'Reconnecting ...'
                @db = PG::Connection.open(@conn_opts)
                return execute(query)
            rescue PG::Error => err
                STDERR.puts "Exception occurred: '#{err}':\n#{query}"
            end
            return y
        end

    end

end

#-  vim:set syntax=ruby:
