module Migrations
  module Statements
    struct CreateTable
      property :name
      property :columns

      def initialize @name : String, @columns : Array(Column)
      end

      def render : RenderedStatement
        statement = "CREATE TABLE #{@name} ("

        statement += @columns.map {|c| c.render}.join(", ")

        statement += "\n)"

        RenderedStatement.new(statement, [] of String)
      end

    end
  end
end
