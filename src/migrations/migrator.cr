require "./postgres"
require "./runner"
require "./yaml_runner"

module Migrations
  class Migrator
    def self.rewind
      new.rollback_last_migration
    end

    def self.migrate
      migrator = new
      if migrator.needs_migrations?
        migrator.run_pending_migrations
      else
        puts "Database is up to date"
      end
    end


    @files = [] of String
    @database :: Postgres
    @migrations = [] of String
    @pending_migrations = [] of String

    def initialize
      @database = Postgres.new

      look_for_files
      verify_migrations_table_exists
      get_migration_list
    end

    def migrations_dir
      "migrations/"
    end

    def look_for_files
      Dir.glob("migrations/*.yml") do |file_path|
        @files << file_path.gsub(/#{migrations_dir}/,"")
      end
    end

    def verify_migrations_table_exists
      unless @database.table_exist? :schema_migrations
        Migrations::Runner.new(@database).run do
          create_table :schema_migrations do
            column :migration_id, String
          end
        end
      end
    end

    def get_migration_list
      result = @database.exec("SELECT * FROM schema_migrations")

      result.rows.each do |row|
        first = row[0]
        if first.is_a? String
          @migrations << first
        end
      end

      @pending_migrations = @files.map { |name| $~[1] if name =~ /^(\d+)_.+$/ } - @migrations
    end

    def needs_migrations?
      @pending_migrations.size > 0
    end

    def run_pending_migrations
      puts "pending migrations: "
      pending_migrations = @files.map { |name| $~[1] if name =~ /^(\d+)_.+$/ } - @migrations
      puts "\t #{pending_migrations.join ", " }"

      pending_migrations.compact
                        .sort {|a, b| a.to_i <=> b.to_i }
                        .each {|number| run_migration number }
    end

    def run_migration number
      index = @files.index {|f| f =~ /^#{number}/ }
      return unless index
      puts "Migrating... #{@files[index]}"
      YamlRunner.new(File.join(migrations_dir, @files[index]), @database).run
      log_success number
    end

    def log_success number
      query = <<-SQL
        INSERT INTO schema_migrations (migration_id) VALUES($1::text)
      SQL

      @database.exec query, [number]
    end

    def rollback_last_migration
    end

  end
end
