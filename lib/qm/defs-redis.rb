#-  Ruby source code

#-  defs-redis.rb ~~
#                                                       ~~ (c) SRW, 03 Feb 2015
#                                                   ~~ last updated 04 Feb 2015

require 'json'
require 'redis'

module QM

    class RedisApiStore

        def close()
          # This method documentation.
            @db.quit if defined?(@db)
            return
        end

        def connect(opts = {})
          # This method needs documentation.
            if opts.has_key?(:redis) then
              # Try to use the "hiredis" driver to boost performance, and fall
              # back to a non-native driver. This is the same strategy that the
              # Node.js version uses. There is also a nifty way to accomplish
              # the same thing from the Gemfile alone (http://git.io/bZb1).
                begin
                    @db ||= Redis.new({
                        driver: 'hiredis'.to_sym,
                        url: opts[:redis]
                    })
                rescue RuntimeError
                  # The  "hiredis" driver was not available, either because the
                  # gem was not included in the app's Gemfile or else because
                  # this Ruby engine cannot use native C extensions.
                    @db ||= Redis.new({
                        url: opts[:redis]
                    })
                end
                collect_garbage
                STDOUT.puts 'API: Redis storage is ready.'
            end
            return @db
        end

        def get_avar(params)
          # This method needs documentation.
            collect_garbage
            y = @db.hget(params.join('&'), 'body')
            @db.expire(params.join('&'), @settings.avar_ttl.to_i) if y
            return (y.nil?) ? '{}' : y
        end

        def get_list(params)
          # This method needs documentation.
            collect_garbage
            y = @db.smembers('$:' + params.join('&'))
            return (y.nil?) ? '[]' : y.to_json
        end

        def initialize(opts = {})
          # This constructor needs documentation.
            @settings = opts
        end

        def set_avar(params)
          # This method needs documentation.
            collect_garbage
            body, box, key = params.last, params[0], params[1]
            hash_key = box + '&' + key
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

        private

        def collect_garbage()
          # This method needs documentation.
            return if defined?(@last_gc_date) and
                    ((Time.now - @last_gc_date) < @settings.gc_interval)
            @last_gc_date = Time.now
            @db.keys('$:*').each do |queue|
                box = queue.gsub(/^\$\:([\w\-]+)[&][\w\-]+/, "$1") { $1 }
                @db.smembers(queue).each do |key|
                    @db.srem(queue, key) unless @db.exists(box + '&' + key)
                end
            end
            STDOUT.puts 'Finished collecting garbage.'
            return
        end

    end

  # NOTE: There is no 'RedisLogStore' class.

end

#-  vim:set syntax=ruby:
