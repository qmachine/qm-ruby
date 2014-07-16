#-  Ruby gem specification file

#-  qm.gemspec ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 16 Jul 2014

Gem::Specification.new do |spec|

    spec.author = 'Sean Wilkinson'

    spec.date = Time.now

    spec.description = 'This is a port of the QMachine web service.'

    spec.email = 'sean@mathbiol.org'

    spec.extra_rdoc_files = [
        'LICENSE',
        'README.md'
    ]

    spec.files = [
        'lib/qm.rb',
        'lib/server.rb'
    ]

    spec.homepage = 'https://www.qmachine.org'

    spec.license = 'Apache 2.0'

    spec.metadata = {
        'issue_tracker' => 'https://github.com/qmachine/qm-ruby/issues'
    }

    spec.name = 'qm'

    spec.summary = %q{A platform for World Wide Computing}

    spec.version = '1.1.11'

  # Specify dependencies

    spec.add_runtime_dependency('json', '1.8.1')
    spec.add_runtime_dependency('sinatra', '1.4.5')
    spec.add_runtime_dependency('sinatra-cross_origin', '0.3.2')
    spec.add_runtime_dependency('sqlite3', '1.3.9')
    spec.add_runtime_dependency('thin', '1.6.2')

end

#-  vim:set syntax=ruby:
