module Migrations
  abstract class Database
    abstract def initialize(
          server = "localhost",
          port = 5432,
          database = "migrations_test",
          user = "",
          pass = ""
      )

    abstract def exec(string : String, parameters)

    abstract def exec_silent(string : String, parameters)

    abstract def exec(query : String)

    abstract def table_exist?(name : Symbol)
  end
end
