qm
==


The `qm` gem for [Ruby](http://www.ruby-lang.org/) includes a
[QMachine](https://www.qmachine.org/) API server and a web server. It uses
[MongoDB](http://www.mongodb.org/) for persistent storage, and it can
optionally log traffic data into a different MongoDB collection instead of
logging to stdout. A client is also in development.

Note that support for [PostgreSQL](http://www.postgresql.org/),
[Redis](http://redis.io/), and [SQLite](https://www.sqlite.org/) for storage is
also available but not recommended for production yet. SQLite, in particular,
may or may not wreak havoc when deploying to [Heroku](https://www.heroku.com/),
where it presents a number of
[potential obstacles](https://devcenter.heroku.com/articles/sqlite3).

For more information, please see the
[manual](https://docs.qmachine.org/en/latest/ruby.html).

===

[![Gem Version](https://badge.fury.io/rb/qm.svg)](http://badge.fury.io/rb/qm) [![Dependency Status](https://gemnasium.com/qmachine/qm-ruby.png)](https://gemnasium.com/qmachine/qm-ruby)

