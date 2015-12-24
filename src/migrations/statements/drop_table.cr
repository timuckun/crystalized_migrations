module Migrations
  module Statements
    struct DropTable
      property :name

      def initialize(@name)
      end

      def render : RenderedStatement
        RenderedStatement.new("DROP TABLE #{@name}", [] of String)
      end
    end
  end
end
