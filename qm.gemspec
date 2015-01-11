#-  Ruby gem specification file

#-  qm.gemspec ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 11 Jan 2015

Gem::Specification.new do |spec|

    spec.author = 'Sean Wilkinson'

    spec.date = Time.now

    spec.description = 'Ruby port of QMachine web service + in-progress client'

    spec.email = 'sean@mathbiol.org'

    spec.extra_rdoc_files = [
        'LICENSE',
        'README.md'
    ]

    spec.files = [
        'lib/client.rb',
        'lib/defs-mongo.rb',
        'lib/qm.rb',
        'lib/service.rb'
    ]

    spec.homepage = 'https://www.qmachine.org'

    spec.license = 'Apache-2.0'

    spec.metadata = {
        'issue_tracker' => 'https://github.com/qmachine/qm-ruby/issues'
    }

    spec.name = 'qm'

    spec.summary = %q{QMachine: A platform for World Wide Computing}

    spec.version = '1.2.1'

  # Specify dependencies

    spec.add_runtime_dependency('bson_ext', '1.11.1')
    spec.add_runtime_dependency('json', '1.8.2')
    spec.add_runtime_dependency('httparty', '0.13.3')
    spec.add_runtime_dependency('mongo', '1.11.1')
    spec.add_runtime_dependency('sinatra', '1.4.5')
    spec.add_runtime_dependency('sinatra-cross_origin', '0.3.2')

end

#-  vim:set syntax=ruby:
