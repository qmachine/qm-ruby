#-  Ruby source code

#-  client-demo.rb ~~
#                                                       ~~ (c) SRW, 17 Nov 2014
#                                                   ~~ last updated 05 Feb 2015

require 'rubygems'
require 'qm/client'

qm = QM::Client.new(mothership: 'http://localhost:8177')

temp_key = qm.uuid

qm.set_avar(box: 'test-from-ruby', key: temp_key, val: rand)

jobs = qm.get_list(box: 'test-from-ruby', status: 'waiting')

puts "Number of jobs: #{jobs.length}"

puts qm.get_avar(box: 'test-from-ruby', key: temp_key)

#-  vim:set syntax=ruby:
