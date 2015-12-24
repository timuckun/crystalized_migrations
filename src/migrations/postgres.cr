require "pg"

module Migrations
  class Postgres

    def initialize(
          server = "localhost",
          port = 5432,
          database = "migrations_test",
          user = "",
          pass = ""
      )

      connection_string = "postgres://"
      if user.size > 0
        connection_string += user
        connection_string += ":#{pass}" if pass.size > 0
        connection_string += "@"
      end

      connection_string += "#{server}:#{port}/#{database}"

      @pg = PG.connect(connection_string)
    end

    def create_table(name : Symbol)
    end

    def exec(string : String, parameters)
      puts "Executing query: #{string}"
      exec_silent string, parameters
    end

    def exec_silent(string : String, parameters)
      @pg.exec string, parameters
    end

    def exec(query : String)
      @pg.exec query
    end

    def table_exist?(name : Symbol)
      # sniped from the psql \d command
      query = <<-SQL
      SELECT c.oid,
        n.nspname,
        c.relname
      FROM pg_catalog.pg_class c
           LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
      WHERE c.relname = $1::text
        AND pg_catalog.pg_table_is_visible(c.oid)
      ORDER BY 2, 3;
      SQL

      response = @pg.exec(query, [name])
      response.rows.size > 0
    end
  end
end
