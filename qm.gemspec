#-  Ruby gem specification file

#-  qm.gemspec ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 29 Jan 2015

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qm'

Gem::Specification.new do |spec|

    spec.author = 'Sean Wilkinson'

    spec.date = Time.now

    spec.description = 'Ruby port of QMachine web service + in-progress client'

    spec.email = 'sean@mathbiol.org'

    spec.executables = []

    spec.extra_rdoc_files = [
        'LICENSE',
        'README.md'
    ]

    spec.files = [
        'lib/qm/client.rb',
        'lib/qm/defs-mongo.rb',
        'lib/qm.rb',
        'lib/qm/service.rb'
    ]

    spec.homepage = 'https://www.qmachine.org'

    spec.license = 'Apache-2.0'

    spec.metadata = {
        'issue_tracker' => 'https://github.com/qmachine/qm-ruby/issues'
    }

    spec.name = 'qm'

    spec.platform = Gem::Platform::RUBY

    spec.summary = %q{QMachine: A platform for World Wide Computing}

    spec.version = QM::VERSION

  # Specify dependencies

    spec.add_runtime_dependency('bson_ext', '1.12.0')   # requires C extension
    spec.add_runtime_dependency('json', '1.8.2')
    spec.add_runtime_dependency('httparty', '0.13.3')
    spec.add_runtime_dependency('mongo', '1.12.0')
    spec.add_runtime_dependency('sinatra', '1.4.5')
    spec.add_runtime_dependency('sinatra-cross_origin', '0.3.2')
    spec.add_runtime_dependency('unicorn', '4.8.3')     # requires C extension

end

#-  vim:set syntax=ruby:
