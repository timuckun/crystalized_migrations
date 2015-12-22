module Migrations
  struct Table
    property :name
    property :columns

    def initialize @name : String, @columns : Array(Column)
    end

    def render : RenderedStatement
      statement = "CREATE TABLE #{@name} ("

      @columns.each do |column|
        statement += column.render
      end

      statement += "\n)"

      RenderedStatement.new(statement, [] of String)
    end

  end
end
