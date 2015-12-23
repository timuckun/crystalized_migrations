require "./postgres"
require "./runner"
require "./yaml_runner"

module Migrations
  class Migrator
    def self.rewind
      new.migrate :reverse
    end

    def self.migrate
      instance = new
      while instance.needs_migrations?
        instance.migrate :forward
        instance.recalculate
      end

      puts "Database is up to date."
    end


    @files = [] of String
    @database :: Postgres
    @migrations = [] of String
    @pending_migrations = [] of String

    def initialize
      @database = Postgres.new
      look_for_files
      verify_migrations_table_exists
      recalculate
    end

    def recalculate
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

      @migrations = @migrations.compact.sort {|a, b| a.to_i <=> b.to_i }

      @pending_migrations = @files.map { |name| $~[1] if name =~ /^(\d+)_.+$/ } - @migrations
    end

    def needs_migrations?
      @pending_migrations.size > 0
    end

    def run_next_migration
      migrations = @pending_migrations
      if migrations.any?
        run_migration @pending_migrations.first as String
      end
    end

    def file_for_migration(migration_number)
      index = @files.index {|f| f =~ /^#{migration_number}/ }

      if index
        File.join(migrations_dir, @files[index])
      else
        raise "Could not find yml file matching #{migration_number}*.yml"
      end
    end

    def migrate direction
      if direction == :reverse
        rollback_last_migration
        true
      else
        run_next_migration
      end
    rescue e : PG::ResultError
      puts "Error: #{e.message}"
    end

    def run_migration number : String
      migration_file = file_for_migration(number)
      puts "Migrating... #{migration_file}"
      YamlRunner.forward(migration_file, @database)
      log_success number

      nil
    end

    def log_success number
      query = <<-SQL
        INSERT INTO schema_migrations (migration_id) VALUES($1::text)
      SQL

      @database.exec_silent query, [number]
    end

    def rollback_last_migration
      unless @migrations.any?
        puts "No migrations on record"
        return
      end

      migration_file = file_for_migration(@migrations.last)
      puts "Rolling back migration: #{migration_file}"
      YamlRunner.reverse(migration_file, @database)

      remove_log @migrations.last

      nil
    end

    def remove_log number
      query = <<-SQL
        DELETE FROM schema_migrations WHERE migration_id = $1::text
      SQL

      @database.exec_silent query, [number]
    end

  end
end
