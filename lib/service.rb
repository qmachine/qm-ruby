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
#                                                   ~~ last updated 11 Jan 2015

require 'sinatra'
require 'sinatra/cross_origin'

class QMachineService < Sinatra::Base

    register Sinatra::CrossOrigin

    configure do

      # QMachine options

        set avar_ttl:               86400, # seconds
            enable_api_server:      false,
            enable_cors:            false,
            enable_web_server:      false,
            hostname:               '0.0.0.0',
            persistent_storage:     {},
            port:                   8177,
            public_folder:          'public',
            trafficlog_storage:     {}

      # Sinatra mappings and options needed by QMachine.

        mime_type :webapp, 'application/x-web-app-manifest+json'

        set bind: lambda { settings.hostname },
            logging: true,
            run: false,
            static: lambda { settings.enable_web_server }

      # See also: http://www.sinatrarb.com/configuration.html

    end

    error do
      # This "route" handles errors that occur as part of the server-side code.
        hang_up
    end

    helpers do
     # This block defines "subfunctions" for use inside the route definitions.
     # The most important ones are the three functions for interacting with
     # persistent storage: `get_avar`, `get_list`, and `set_avar`. Those three
     # functions are not defined here -- they are defined separately in modules
     # that are loaded at runtime by `QM::launch_service`.

        def hang_up
          # This helper method "hangs up" on a request by sending a nondescript
          # 444 response back to the client, a convention taken from nginx.
            halt [444, {'Content-Type' => 'text/plain'}, ['']]
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
                ((@key.is_a?(String) and @key.match(/^[\w\-]+$/)) or
                (@status.is_a?(String) and @status.match(/^[\w\-]+$/)))
        cross_origin if settings.enable_cors?
    end

    get '/:version/:box' do
      # This route responds to API calls that "read" from persistent storage,
      # such as when checking for new tasks to run or downloading results.
        hang_up unless (@key.is_a?(String) ^ @status.is_a?(String))
        if @key.is_a?(String) then
          # This arm runs when a client requests the value of a specific avar.
            y = get_avar([@box, @key])
        else
          # This arm runs when a client requests a task queue.
            y = get_list([@box, @status])
        end
        return [200, {'Content-Type' => 'application/json'}, [y]]
    end

    post '/:version/:box' do
      # This route responds to API calls that "write" to persistent storage,
      # such as when uploading results or submitting new tasks.
        hang_up unless @key.is_a?(String) and not @status.is_a?(String)
        body = request.body.read
        begin
            x = JSON.parse(body)
        rescue
            hang_up
        end
        hang_up unless (@box == x['box']) and (@key == x['key'])
        if x['status'].is_a?(String) then
          # This arm runs only when a client writes an avar which represents a
          # task description.
            hang_up unless x['status'].match(/^[\w\-]+$/)
            set_avar([@box, @key, x['status'], body])
        else
          # This arm runs when a client is writing a "regular avar".
            set_avar([@box, @key, body])
        end
        return [201, {'Content-Type' => 'text/plain'}, ['']]
    end

    get '/robots.txt' do
      # This route delegates to the web server, if it was enabled at launch and
      # if the appropriate file exists; otherwise, it returns a message to web
      # crawlers instructing them to keep out.
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

#-  vim:set syntax=ruby:
