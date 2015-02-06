#-  Ruby source code

#-  defs-mysql.rb ~~
#                                                       ~~ (c) SRW, 05 Feb 2015
#                                                   ~~ last updated 05 Feb 2015

require 'json'
require 'mysql2'
require 'uri'

module QM

    class MysqlApiStore

        def close()
          # This method documentation.
            @db.close if defined?(@db)
            return
        end

        def connect(opts = {})
          # This method needs documentation.
            if opts.has_key?(:mysql) then
                parsed = URI.parse(opts[:mysql])
                temp = {
                    #database:   parsed.path.gsub('/', ''),
                    host:       parsed.host,
                    port:       parsed.port.to_i,
                    reconnect:  true
                }
                temp[:username] = parsed.user unless parsed.user.nil?
                temp[:password] = parsed.password unless parsed.password.nil?
                dbm = Mysql2::Client.new(temp)
                dbm.query <<-end
                    CREATE DATABASE IF NOT EXISTS #{parsed.path.gsub('/', '')};
                end
                dbm.close
                temp[:database] = parsed.path.gsub('/', '')
                @conn_opts ||= temp
                @db ||= Mysql2::Client.new(@conn_opts)
                execute <<-end
                 -- (init stuff goes here)
                end
                STDOUT.puts 'API: MySQL storage is ready.'
            end
            return @db
        end

        def get_avar(params)
          # This method needs documentation.
            # ...
            return '{}'
        end

        def get_list(params)
          # This method needs documentation.
            # ...
            return '[]'
        end

        def initialize(opts = {})
          # This constructor needs documentation.
            @settings = opts
        end

        def set_avar(params)
          # This method needs documentation.
            # ...
            return
        end

        private

        def execute(query, x = [])
          # This method needs documentation.
            begin
                y = @db.query(query)
            rescue Exception => err
                STDERR.puts "Exception occurred: '#{err}':\n#{query}"
            end
            return y
        end

    end

  # NOTE: There is no "MysqlLogStore" class.

end

#-  vim:set syntax=ruby:
