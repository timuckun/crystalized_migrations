# Crystal Migrations

## Goals

- Provide a yaml-based database migration dsl to be run post-compile for database connected projects.
- Provide a simple, programmatic database api, which can be used as part of a run-time system.
- Both interfaces should be capable subsets of SQL queries, geared towards schema creation and mutation.
- Full type abstraction of variables into database fields.

## Current status

- Prototypical. I've barely run a string through getting it to run migrations from yaml and the api.

## Installation

Eventually, this project will be embeddable in other projects as a shard, something like this:

```
require "crystalized_migrations"
if %w|up down|.include? ARGV
  Migrations::CLI.new.run
end
```

For now, it runs on its own.

## Usage

Make sure to provide a postgres database called "migrations_test" on localhost, owned by your current user, with no password. There's no connection parameter handling code.

```shards install; ./run up``` from the project directory.

## Contributing

Currently, the most valueable feedback is code review. Leave a comment or send me an email.

## Contributors

- [[@robacarp]](https://github.com/robacarp) Robert L. Carpenter - creator, maintainer
