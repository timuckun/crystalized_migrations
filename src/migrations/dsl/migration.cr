require "../structs"

module Migrations
  module DSL
    class Migration
      getter :actions

      @actions = [] of RunnableMigrations

      def create_table name : Symbol | String
        dsl = CreateTable.new(name)
        with dsl yield
        @actions << dsl.compiled_action
      end

    end
  end
end
