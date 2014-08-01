# qm

The `qm` gem for [Ruby](http://www.ruby-lang.org/) implements both the API
server and web server components of [QMachine](https://www.qmachine.org). It
uses [MongoDB](http://www.mongodb.org/) for persistent storage, and it can
optionally log traffic data into a different MongoDB collection instead of
logging to stdout.

The repository contains vestigial definitions for using
[SQLite](https://www.sqlite.org/), but these may evolve away in the future. If
you absolutely must use SQLite, you should take a look at the
[Node.js version](https://github.com/qmachine/qm-nodejs) instead.

Install
-------

To install the latest release, run

    $ gem install qm

===

[![Gem Version](https://badge.fury.io/rb/qm.svg)](http://badge.fury.io/rb/qm) [![Dependency Status](https://gemnasium.com/qmachine/qm-ruby.png)](https://gemnasium.com/qmachine/qm-ruby)

<!-- vim:set syntax=markdown: -->
