# qm

The `qm` gem for [Ruby](http://www.ruby-lang.org/) includes a
[QMachine](https://www.qmachine.org) API server and a web server. It uses
[MongoDB](http://www.mongodb.org/) for persistent storage, and it can
optionally log traffic data into a different MongoDB collection instead of
logging to stdout.

The repository contains vestigial definitions for using
[SQLite](https://www.sqlite.org/), but these may "evolve away" in the future,
primarily due to the
[obstacle it poses](https://devcenter.heroku.com/articles/sqlite3)
to deploying on [Heroku](https://www.heroku.com). If you are absolutely in love
with SQLite (or just hate MongoDB), consider trying the
[Node.js version](https://github.com/qmachine/qm-nodejs) instead.

For more information, please see the
[manual](https://docs.qmachine.org/en/latest/ruby.html).

===

[![Gem Version](https://badge.fury.io/rb/qm.svg)](http://badge.fury.io/rb/qm) [![Dependency Status](https://gemnasium.com/qmachine/qm-ruby.png)](https://gemnasium.com/qmachine/qm-ruby)

<!-- vim:set syntax=markdown: -->
