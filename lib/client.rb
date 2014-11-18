#-  Ruby source code

#-  client.rb ~~
#
#   Currently, this contains simple functions that are useful for constructing
#   a Ruby client, but which by themselves are still slightly too low-level to
#   be convenient. They are modeled after the browser (JS) and R clients.
#
#   One idea for the future is to embed one JS execution context in each
#   `QMachineClient` object and then to load the latest browser client inside.
#   Obviously, that won't coordinate *arbitrary* code -- or even Ruby code --
#   but it will save me from rewriting a client completely from scratch because
#   it is possible to add functions and objects to the JS context which are
#   implemented in Ruby. Thus, instead of writing a client in Ruby that will
#   act like the browser client, the idea is to make Ruby act like a browser so
#   I can reuse the browser client ...
#
#                                                       ~~ (c) SRW, 20 Jul 2014
#                                                   ~~ last updated 17 Nov 2014

require 'httparty'
require 'json'

class QMachineClient

    include HTTParty

    def initialize(options = {mothership: 'https://api.qmachine.org'})
      # This method runs when Ruby calls `QMachineClient.new`.
        @ms = options[:mothership]
        return
    end

    def get_avar(opts = {})
      # This method needs documentation.
        res = self.class.get("#{@ms}/box/#{opts[:box]}?key=#{opts[:key]}")
        if (res.code != 200) then
            raise "Error: #{res.code}"
        end
        return JSON.parse(res.body)
    end

    def get_list(opts = {})
      # This method needs documentation.
        res = self.class.get("#{@ms}/box/#{opts[:box]}?status=#{opts[:status]}")
        if (res.code != 200) then
            raise "Error: #{res.code}"
        end
        return JSON.parse(res.body)
    end

    def set_avar(opts = {})
      # This method needs documentation.
        res = self.class.post("#{@ms}/box/#{opts[:box]}?key=#{opts[:key]}", {
            body: opts.to_json,
            headers: {'Content-Type' => 'application/json'}
        })
        if (res.code != 201) then
            raise "Error: #{res.code}"
        end
        return res.body
    end

    def uuid()
      # This method needs documentation.
        y = ''
        while (y.length < 32) do
            y += rand.to_s[/[0-9]+(?!.)/].to_i.to_s(16)
        end
        return y.slice(0, 32)
    end

end

#-  vim:set syntax=ruby:
