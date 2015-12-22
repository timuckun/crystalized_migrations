require "./dsl/*"

module Migrations
  class Runner
    def initialize @database_connection : Postgres
    end

    def run
      dsl = Migrations::DSL::Migration.new
      with dsl yield

      dsl.actions.map {|a| a.render}.each do |statement|
        @database_connection.exec statement.statement, statement.values
      end
    end
  end
end
