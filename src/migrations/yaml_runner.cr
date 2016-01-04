require "yaml"
require "./structs"

module Migrations
  class YamlRunner
    getter :migration
    setter :migration
    getter :data

    def self.migrate(file, database)
      runner = new file, database
      runner.migrate

      if runner.can_migrate?
        runner.migrate
      else
        raise "Cannot migrate, no 'up' migration found in #{file}"
      end
    end

    def self.rollback(file, database)
      runner = new file, database
      if runner.can_rollback?
        runner.rollback
      else
        raise "Cannot rollback, no 'down' migration found in #{file}"
      end
    end

    def initialize(file, @database)
      data  = File.read(file)
      @data = (YAML.load(data) as Hash)
      @forward = @data["up"] if @data.keys.includes? "up"
      @reverse = @data["down"] if @data.keys.includes? "down"
      # fail YAML::ParseException.new "Invalid YAML file #{file}"
    end

    def can_migrate?
      ! @forward.nil?
    end

    def can_rollback?
      ! @reverse.nil?
    end

    def migrate
      @migration = @forward
      run
    end

    def rollback
      @migration = @reverse
      run
    end

    def run
      migration = @migration
      return unless migration.is_a? Hash(YAML::Type, YAML::Type)

      steps = [] of RunnableMigrations

      migration.each_key do |key|
        params = migration[key] as Hash

        case key
        when "create_table"
          steps << create_table(params)
        when "drop_table"
          steps << drop_table(params)
        when "add_column"
          steps << add_column(params)
        else
          raise "Couldn't run #{key} migration, it's probably not implemented yet"
        end
      end

      steps.map {|a| a.render}.each do |statement|
        @database.exec statement.statement, statement.values
      end

      true
    end

    private def create_table(structure)
      raise "Create Table needs a name" unless structure.has_key? "name"
      raise "Create Table needs an array of columns" unless structure.has_key? "columns"

      columns = (structure["columns"] as Array).map do |column|
        next unless column.is_a? Hash
        build_column column
      end

      Statements::CreateTable.new structure["name"] as String, columns.compact as Array(Statements::Column)
    end

    private def drop_table(meta)
      raise "Drop Table needs a name" unless meta.has_key? "name"

      Statements::DropTable.new meta["name"]
    end

    def add_column(meta)
      raise "Add Column needs a table" unless meta.has_key? "to_table"
      raise "Add Column needs a column name and type" unless meta.has_key?("name") && meta.has_key?("type")

      column = Statements::Column.new meta["name"] as String, meta["type"] as String
      Statements::AddColumn.new meta["to_table"] as String, column
    end

    private def build_column(meta : Hash)
      column = Statements::Column.new meta.first_key as String, meta.first_value as String

      if meta.keys.includes? "null"
        column.null = meta["null"]? == "true"
      end

      column.default = meta["default"]? if meta.keys.includes? "default"

      if meta.keys.includes? "unique"
        column.unique = true if meta["unique"]? == "true"
      end

      column.primary_key = true if meta["primary_key"]? == true

      column
    end
  end
end
