require "../structs"

module Migrations
  module DSL
    class CreateTable

      def initialize(name : Symbol | String)
        if name.is_a? Symbol
          name = name.to_s
        end

        @name = name
      end

      @columns = [] of Statements::Column

      def column(name : String | Symbol, type : Class, *opts)
        if name.is_a? Symbol
          name = name.to_s
        end

        if type.is_a? Class
          type = type.to_s
        end

        @columns << Statements::Column.new(name, type)
      end

      def compiled_action
        Statements::CreateTable.new @name, @columns
      end

      def render
        Statements::CreateTable.new(@name, @columns)
      end

    end
  end
end
