module Migrations
  module Statements
    struct AddColumn

      def initialize(@table : String, @column : Column)
      end

      def render : RenderedStatement
        RenderedStatement.new "ALTER TABLE #{@table} ADD COLUMN #{@column.render}", [] of String
      end
    end
  end
end
