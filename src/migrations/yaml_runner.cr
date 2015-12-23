require "yaml"
require "./structs"

module Migrations
  class YamlRunner
    def initialize file, @database
      data = File.read(file)
      @data = (YAML.load(data) as Hash)
      @migration = @data["up"] if @data["up"]
      @reverse   = @data["down"] if @data["down"]
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
        else
          raise "Couldn't run #{key} migration, it's probably not implemented yet"
        end
      end

      steps.map {|a| a.render}.each do |statement|
        @database.exec statement.statement, statement.values
      end

      true
    end

    def create_table structure
      raise "Create Table needs a name" unless structure.has_key? "name"
      raise "Create Table needs an array of columns" unless structure.has_key? "columns"

      columns = (structure["columns"] as Array).map do |column|
        next unless column.is_a? Hash
        Statements::Column.new column.first_key as String, column.first_value as String
      end

      Statements::CreateTable.new structure["name"] as String, columns.compact as Array(Statements::Column)
    end

    def drop_table meta
      puts meta
      Statements::DropTable.new ""
    end

  end
end
