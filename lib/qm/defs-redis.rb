#-  Ruby source code

#-  defs-redis.rb ~~
#                                                       ~~ (c) SRW, 03 Feb 2015
#                                                   ~~ last updated 03 Feb 2015

require 'json'
require 'redis'

module QM

    class RedisApiStore

        def close()
          # This method documentation.
            @db.quit if @db.respond_to?('quit')
            return
        end

        def connect(opts = {})
          # This method needs documentation.
            if opts.has_key?(:redis) then
                @db ||= Redis.new({url: opts[:redis]})
            end
            return @db
        end

        def get_avar(params)
          # This method needs documentation.
            hash_key = "#{params[0]}&#{params[1]}"
            y = @db.hget(hash_key, 'body')
            @db.expire(hash_key, @settings.avar_ttl.to_i) if y
            return (y.nil?) ? '{}' : y
        end

        def get_list(params)
          # This method needs documentation.
            y = @db.smembers("$:#{params[0]}&#{params[1]}")
            return (y.nil?) ? '[]' : y.to_json
        end

        def initialize(opts = {})
          # This constructor needs documentation.
            @settings = opts
        end

        def set_avar(params)
          # This method needs documentation.
            body, box, key = params.last, params[0], params[1]
            hash_key = "#{box}&#{key}"
            status_prev = @db.hget(hash_key, 'status')
            @db.multi do |multi|
                multi.srem('$:' + box + '&' + status_prev, key) if status_prev
                if params.length == 4 then
                    multi.sadd('$:' + box + '&' + params[2], key)
                    multi.hmset(hash_key, 'body', body, 'status', params[2])
                else
                    multi.hdel(hash_key, 'status')
                    multi.hset(hash_key, 'body', body)
                end
                multi.expire(hash_key, @settings.avar_ttl.to_i)
            end
            return
        end

    end

  # NOTE: There is no 'RedisLogStore' class.

end

#-  vim:set syntax=ruby:
