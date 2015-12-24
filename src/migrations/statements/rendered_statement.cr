module Migrations
  struct RenderedStatement
    property :values
    property :statement

    def initialize(@statement : String, @values : Array(String))
    end
  end
end
