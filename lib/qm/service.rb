#-  Ruby source code

#-  service.rb ~~
#
#   This file is derived from the original "teaching version" of QMachine,
#   which used Sinatra and SQLite in a self-contained way. Where that version
#   sought to abbreviate the original Node.js codebase as succinctly as
#   possible, this version attempts to provide a more similar interface and
#   level of configurability. Performance will *never* be a priority in the
#   Ruby port.
#
#   NOTE: Using a "%" character incorrectly in a URL will cause you great
#   anguish, and there isn't a good way for me to handle this problem "softly"
#   because it is the expected behavior (http://git.io/bmKr2w). Thus, you will
#   tend to see "Bad Request" on your screen if you insist on using "%" as part
#   of a 'box', 'key', or 'status' value.
#
#                                                       ~~ (c) SRW, 24 Apr 2013
#                                                   ~~ last updated 05 Feb 2015

require 'qm/storage'
require 'sinatra/base'
require 'sinatra/cross_origin'

module QM

    class Service < Sinatra::Base

        register Sinatra::CrossOrigin, QM::StorageConnectors

        configure do

          # MIME types that may be missing

            mime_type({
                webapp:             'application/x-web-app-manifest+json'
            })

          # QMachine definitions

            qm_lazy = {
                api_db:             lambda { connect_api_store },
                bind:               lambda { settings.hostname },
                log_db:             lambda { connect_log_store },
                logging:            lambda { settings.log_db.nil? },
                static:             lambda { settings.enable_web_server }
            }

            qm_options = {
                avar_ttl:           86400,  # seconds (24 * 60 * 60 = 1 day)
                enable_api_server:  false,
                enable_cors:        false,
                enable_web_server:  false,
                gc_interval:        60,     # seconds
                hostname:           '0.0.0.0',
                max_body_size:      65536,  # bytes (64 * 1024 = 64 KB)
                persistent_storage: {},
                port:               8177,
                public_folder:      'public',
                trafficlog_storage: {},
                worker_procs:       1
            }

          # Save the configuration :-)

            set(qm_lazy.merge(qm_options).merge({

              # The first two entries here are needed by `QM.create_app`.

                qm_lazy:            qm_lazy.keys,
                qm_options:         qm_options.keys,

              # The rest are Rack / Sinatra mappings.

                raise_errors:       false,
                run:                false,
                show_exceptions:    false,
                x_cascade:          false

            }))

        end

        error do
          # This "route" handles errors and exceptions that occur in the
          # server-side code.
            hang_up
        end

        helpers do
          # This block defines "subfunctions" for use inside the route
          # definitions.

            def hang_up
              # This helper literally "hangs up" on the request by immediately
              # halting further processing, responding with a nondescript 444
              # status code and an empty body, and then closing the connection.
              # Unfortunately, closing the connection in this way causes
              # problems in the Node.js implementation, which suggests that
              # this is not the correct solution for all concurrency models.
                headers = {
                    'Connection' => 'close',
                    'Content-Type' => 'text/plain'
                }
                halt [444, headers, ['']]
            end

            def log_to_db()
              # This helper function needs documentation.
                settings.log_db.log(request)
            end

        end

        not_found do
          # This "route" handles requests that didn't match.
            hang_up
        end

      # Filter definitions

        after do
          # After every successful request, if logging to stdout has been
          # disabled, write a new entry into the traffic log database.
            log_to_db unless response.status == 444 or settings.logging == true
        end

        before '/:version/:box' do
          # When any request matches the pattern given, this block will execute
          # before the route that corresponds to its HTTP method. The code here
          # will validate the request's parameters and store them as instance
          # variables that will be available to the corresponding route's code.
            @box, @key, @status = params[:box], params[:key], params[:status]
            hang_up unless settings.enable_api_server? and
                ((params[:version] == 'box') or (params[:version] == 'v1')) and
                (@key.is_a?(String) ^ @status.is_a?(String)) and
                (@box + @key.to_s + @status.to_s).match(/^[\w\-]+$/) and
                (request.content_length.to_s.to_i(10) < settings.max_body_size)
            cross_origin if settings.enable_cors?
        end

      # Route definitions

        get '/:version/:box' do
          # This route responds to API calls that "read" from persistent
          # storage, such as when checking for new tasks to run or downloading
          # results.
            if @key.is_a?(String) then
              # This arm handles a request to read a specific avar.
                y = settings.api_db.get_avar([@box, @key])
            else
              # This arm handles a request for a list of tasks by "status".
                y = settings.api_db.get_list([@box, @status])
            end
            return [200, {'Content-Type' => 'application/json'}, [y]]
        end

        post '/:version/:box' do
          # This route responds to API calls that "write" to persistent
          # storage, such as when uploading results or submitting new tasks.
            hang_up unless @key.is_a?(String)
            body = request.body.read
            begin
                x = JSON.parse(body)
            rescue JSON::ParserError
                hang_up
            end
            hang_up unless (@box == x['box']) and (@key == x['key'])
            if x['status'].is_a?(String) then
              # This arm runs only when a client writes an avar which
              # represents a task description.
                hang_up unless x['status'].match(/^[\w\-]+$/)
                settings.api_db.set_avar([@box, @key, x['status'], body])
            else
              # This arm runs when a client is writing a "regular avar".
                settings.api_db.set_avar([@box, @key, body])
            end
            return [201, {'Content-Type' => 'text/plain'}, ['']]
        end

        get '/robots.txt' do
          # This route delegates to the web server, if it was enabled at launch
          # and if the appropriate file exists; otherwise, it returns a message
          # to web crawlers instructing them to keep out.
            robots_file = File.join(settings.public_folder, 'robots.txt')
            if settings.enable_web_server? then
                pass if File.exists?(robots_file)
                y = "User-agent: *\nDisallow: /box/\nDisallow: /v1/\n"
            else
                y = "User-agent: *\nDisallow: /\n"
            end
            return [200, {'Content-Type' => 'text/plain'}, [y]]
        end

        get '/' do
          # This route enables a static index page to be served from the public
          # folder, if and only if QM's web server has been enabled.
            hang_up unless settings.enable_web_server?
            send_file(File.join(settings.public_folder, 'index.html'))
        end

    end

end

#-  vim:set syntax=ruby:
