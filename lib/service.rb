#-  Ruby source code

#-  service.rb ~~
#
#   This file is a hacked-up version of the "teaching version" of QMachine,
#   and the rest of this introduction reflects that.
#
#   This is a self-contained Rack app that uses Sinatra's domain-specific
#   language (DSL) in tandem with SQLite to implement a teaching version of
#   QMachine. The idea here is to pack most of the functionality of the
#   original Node.js codebase into a single file that reads like pseudo-code.
#
#   Of course, there are some caveats. This version succeeds in abbreviating
#   the original codebase, but it doesn't support all of the original options
#   yet. The code can also be hard to modify if you're unfamiliar with Sinatra,
#   because Ruby's scoping rules are very different from JavaScript's, and
#   Sinatra's DSL makes things even "worse", to be honest. My advice here is,
#   don't think too hard about it. Just enjoy it.
#
#   NOTE: Using a "%" character incorrectly in a URL will cause you great
#   anguish, and there isn't a good way for me to handle this problem "softly"
#   because it is the expected behavior (http://git.io/bmKr2w). Thus, you will
#   tend to see "Bad Request" on your screen if you insist on using "%" as part
#   of a 'box', 'key', or 'status' value.
#
#                                                       ~~ (c) SRW, 24 Apr 2013
#                                                   ~~ last updated 16 Jul 2014

require 'json'
require 'sinatra'
require 'sinatra/cross_origin'
require 'sqlite3'

class QMachineService < Sinatra::Base

    register Sinatra::CrossOrigin

    configure do

      # QMachine options

        set avar_ttl:               86400, # seconds
            enable_api_server:      false,
            enable_CORS:            false,
            enable_web_server:      false,
            hostname:               '0.0.0.0',
            persistent_storage:     'qm.db',
            port:                   8177,
            public_folder:          'public'

      # Sinatra mappings and options needed by QMachine.

        mime_type webapp: 'application/x-web-app-manifest+json'
        set bind: :hostname, run: false, static: :enable_web_server

      # See also: http://www.sinatrarb.com/configuration.html

    end

    error do
      # This "route" handles errors that occur as part of the server-side code.
        hang_up
    end

    helpers do
     # This block defines subfunctions for use inside the route definitions.

        def sqlite(query)
          # This helper method helps DRY out the code for database queries, and
          # it does so in an incredibly robust and inefficient way -- by
          # creating the table and evicting expired rows before every single
          # query. A caveat, of course, is that the special ":memory:" database
          # doesn't work correctly, but ":memory:" isn't *persistent* storage
          # anyway. Also, I have omitted indexing on `box_status` for obvious
          # reasons :-P
            begin
                db = SQLite3::Database.open(settings.persistent_storage)
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

        def hang_up
          # This helper method "hangs up" on a request by sending a nondescript
          # 444 response back to the client, a convention taken from nginx.
            halt [444, {'Content-Type' => 'text/plain'}, ['']]
        end

        def now_plus(dt)
          # This helper method computes a date (in milliseconds) that is
          # specified by an offset `dt` (in seconds).
            return (1000 * (Time.now.to_f + dt)).to_i
        end

    end

    not_found do
      # This "route" handles requests that didn't match.
        hang_up
    end

  # Route definitions

    before '/*/*' do |version, box|
      # When any request matches the pattern given, this block will execute
      # before the route that corresponds to its HTTP method. The code here
      # will validate the request's parameters and store them as instance
      # variables that will be available to the corresponding route's code.
        @box, @key, @status = box, params[:key], params[:status]
        hang_up unless (settings.enable_api_server?) and
                ((version == 'box') or (version == 'v1')) and
                (@box.match(/^[\w\-]+$/)) and
                ((@key.is_a?(String) and @key.match(/^[A-Za-z0-9]+$/)) or
                (@status.is_a?(String) and @status.match(/^[A-Za-z0-9]+$/)))
        cross_origin if settings.enable_CORS?
    end

    get '/:version/:box' do
      # This route responds to API calls that "read" from persistent storage,
      # such as when checking for new tasks to run or downloading results.
        hang_up unless (@key.is_a?(String) ^ @status.is_a?(String))
        bk, bs = "#{@box}&#{@key}", "#{@box}&#{@status}"
        if @key.is_a?(String) then
          # This arm runs when a client requests the value of a specific avar.
            x = sqlite("SELECT body FROM avars WHERE box_key = '#{bk}'")
            y = (x.length == 0) ? '{}' : x[0][0]
        else
          # This arm runs when a client requests a task queue.
            x = sqlite("SELECT key FROM avars WHERE box_status = '#{bs}'")
            y = (x.length == 0) ? '[]' : (x.map {|row| row[0]}).to_json
        end
        return [200, {'Content-Type' => 'application/json'}, [y]]
    end

    post '/:version/:box' do
      # This route responds to API calls that "write" to persistent storage,
      # such as when uploading results or submitting new tasks.
        hang_up unless @key.is_a?(String) and not @status.is_a?(String)
        body, ed = request.body.read, now_plus(settings.avar_ttl)
        x = JSON.parse(body)
        hang_up unless (@box == x['box']) and (@key == x['key'])
        bk, bs = "#{@box}&#{@key}", "#{@box}&#{x['status']}"
        if x['status'].is_a?(String) then
          # This arm runs only when a client writes an avar which represents a
          # task description.
            hang_up unless x['status'].match(/^[A-Za-z0-9]+$/)
            sqlite("INSERT OR REPLACE INTO avars
                        (body, box_key, box_status, exp_date, key)
                    VALUES ('#{body}', '#{bk}', '#{bs}', #{ed}, '#{@key}')")
        else
          # This arm runs when a client is writing a "regular avar".
            sqlite("INSERT OR REPLACE INTO avars (body, box_key, exp_date)
                    VALUES ('#{body}', '#{bk}', #{ed})")
        end
        return [201, {'Content-Type' => 'text/plain'}, ['']]
    end

    get '/' do
      # This route enables a static index page to be served from the public
      # folder, if and only if QM's web server has been enabled.
        hang_up unless settings.enable_web_server?
        send_file(File.join(settings.public_folder, 'index.html'))
    end

end

#-  vim:set syntax=ruby:
