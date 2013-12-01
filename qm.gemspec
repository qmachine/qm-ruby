#-  Ruby gem specification file

#-  qm.gemspec ~~
#                                                       ~~ (c) SRW, 12 Apr 2013
#                                                   ~~ last updated 01 Dec 2013

Gem::Specification.new do |spec|

    spec.author = 'Sean Wilkinson'

    spec.date = Time.now

    spec.description = 'This is a *very incomplete* port of QMachine.'

    spec.email = 'sean@mathbiol.org'

    spec.extra_rdoc_files = [
        'LICENSE',
        'README.md'
    ]

    spec.files = [
        'lib/qm.rb'
    ]

    spec.homepage = 'https://www.qmachine.org'

    spec.license = 'Apache 2.0'

    spec.name = 'qm'

    spec.summary = %q{A platform for World Wide Computing}

    spec.version = '1.1.4'

end

#-  vim:set syntax=ruby:
