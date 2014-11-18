#-  Ruby source code

#-  client-demo.rb ~~
#                                                       ~~ (c) SRW, 17 Nov 2014
#                                                   ~~ last updated 17 Nov 2014

require 'rubygems'
require 'qm'

qm = QM::launch_client()

temp_key = qm.uuid()

qm.set_avar({box: 'test-from-ruby', key: temp_key, val: rand})

jobs = qm.get_list({box: 'test-from-ruby', status: 'waiting'})

puts "Number of jobs: #{jobs.length}"

y = qm.get_avar({box: 'test-from-ruby', key: temp_key})

puts y

#-  vim:set syntax=ruby:
