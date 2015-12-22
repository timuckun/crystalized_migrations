module Migrations
  struct Column
    property :name
    property :type

    def initialize @name : String, @type : String
    end

    def render
      "\n  #{@name} #{render_type @type}"
    end

    def render_type type : String | Symbol | Class
      if type.is_a? Class || type.is_a? Symbol
        type = type.to_s
      end

      case type
      when /String/i
        "varchar(255)"
      when /Int/i
        "bigint"
      when /Boolean/i
        "boolean"
      else
        type
      end
    end
  end
end
