module Migrations
  module Statements
    struct Column
      property :name
      property :type

      property :null
      property :default
      property :unique
      property :primary_key

      def initialize(
            @name : String,
            @type : String,
            null    = nil,
            default = nil,
            unique  = nil,
            primary_key = false
          )

        @null        = null
        @default     = default
        @unique      = unique
        @primary_key = primary_key
      end

      def render_options
        any_options = [@null, @default, @unique, @primary_key].compact.any?
        return "" unless any_options

        s = [] of String

        # using @null like a trinary
        s << "NOT NULL" if @null === false
        s << "NULL"     if @null === true

        s << "UNIQUE"   if @unique
        s << "DEFAULT #{@default}" if @default
        s << "PRIMARY KEY" if @primary_key

        s.join(' ')
      end

      def render
        "\n  #{@name} #{render_type @type} #{render_options}"
      end

      def render_type(type : String | Symbol | Class)
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
        when /Time/i
          "timestamp with time zone"
        else
          type
        end
      end
    end
  end
end

      # More types from postgres:
      #   Aliases	Description
      #   bigint	int8	signed eight-byte integer
      #   bigserial	serial8	autoincrementing eight-byte integer
      #   bit [ (n) ]	 	fixed-length bit string
      #   bit varying [ (n) ]	varbit	variable-length bit string
      #   boolean	bool	logical Boolean (true/false)
      #   box	 	rectangular box on a plane
      #   bytea	 	binary data ("byte array")
      #   character [ (n) ]	char [ (n) ]	fixed-length character string
      #   character varying [ (n) ]	varchar [ (n) ]	variable-length character string
      #   cidr	 	IPv4 or IPv6 network address
      #   circle	 	circle on a plane
      #   date	 	calendar date (year, month, day)
      #   double precision	float8	double precision floating-point number (8 bytes)
      #   inet	 	IPv4 or IPv6 host address
      #   integer	int, int4	signed four-byte integer
      #   interval [ fields ] [ (p) ]	 	time span
      #   json	 	textual JSON data
      #   jsonb	 	binary JSON data, decomposed
      #   line	 	infinite line on a plane
      #   lseg	 	line segment on a plane
      #   macaddr	 	MAC (Media Access Control) address
      #   money	 	currency amount
      #   numeric [ (p, s) ]	decimal [ (p, s) ]	exact numeric of selectable precision
      #   path	 	geometric path on a plane
      #   pg_lsn	 	PostgreSQL Log Sequence Number
      #   point	 	geometric point on a plane
      #   polygon	 	closed geometric path on a plane
      #   real	float4	single precision floating-point number (4 bytes)
      #   smallint	int2	signed two-byte integer
      #   smallserial	serial2	autoincrementing two-byte integer
      #   serial	serial4	autoincrementing four-byte integer
      #   text	 	variable-length character string
      #   time [ (p) ] [ without time zone ]	 	time of day (no time zone)
      #   time [ (p) ] with time zone	timetz	time of day, including time zone
      #   timestamp [ (p) ] [ without time zone ]	 	date and time (no time zone)
      #   timestamp [ (p) ] with time zone	timestamptz	date and time, including time zone
      #   tsquery	 	text search query
      #   tsvector	 	text search document
      #   txid_snapshot	 	user-level transaction ID snapshot
      #   uuid	 	universally unique identifier
      #   xml	 	XML data
