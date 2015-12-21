require "../rendered_statement"

module Migrations
  module DSL
    class Migration
      @statements = [] of RenderedStatement

      def create_table name : Symbol
        dsl = CreateTable.new(name)
        with dsl yield

        @statements << dsl.render
      end

      def each_statement
        @statements.each do |statement|
          yield statement
        end
      end
    end
  end
end
