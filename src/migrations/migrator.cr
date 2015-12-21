require "./postgres"
require "./runner"

require "yaml"

module Migrations
  class Migrator
    def self.run
      new.run
    end

    @files = [] of String
    @database :: Postgres
    @migrations = [] of String

    def initialize
      @database = Postgres.new
    end

    def migrations_dir
      "migrations/"
    end

    def run
      look_for_files
      verify_migrations_table_exists
      get_migration_list
      run_pending_migrations
    end

    def look_for_files
      Dir.glob("migrations/*.yml") do |file_path|
        @files << file_path.gsub(/#{migrations_dir}/,"")
      end

      puts @files
    end

    def verify_migrations_table_exists
      puts "verifying migrations table exists"
      unless @database.table_exist? :schema_migrations
        puts "\t it doesnt't, creating"

        Migrations::Runner.new(@database).run do
          create_table :schema_migrations do
            column :migration_id, String
          end
        end

        @database.create_table :schema_migrations
      else
        puts "\t it does"
      end
    end

    def get_migration_list
      puts "fetching migrations table from database"
      result = @database.exec("SELECT * FROM schema_migrations")

      result.rows.each do |row|
        first = row[0]
        if first.is_a? String
          @migrations << first
        end
      end
    end

    def run_pending_migrations
      puts "running pending migrations"
      pending_migrations = @files.map { |name| $~[1] if name =~ /^(\d+)_.+$/ } - @migrations
      puts pending_migrations
      pending_migrations.each {|number| run_migration number}
    end

    def run_migration number
      index = @files.index {|f| f =~ /^#{number}/ }
      return unless index
      puts @files[index]
      parse @files[index]
    end

    def parse file
      source = File.read(migrations_dir + file)
      migration = (YAML.load(source) as Hash)["up"]
      puts migration
    end
  end
end

Migrations::Migrator.run
