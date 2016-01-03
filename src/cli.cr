require "./migrations/*"

module Migrations
  class CLI
    def run
      args = ARGV
      case
      when args.size < 1
        usage
      when args[0] == "up"
        Migrator.new(database_engine).migrate :forward
      when args[0] == "down"
        Migrator.new(database_engine).migrate :reverse
      else
        usage
      end
    end

    def database_engine
      Migrations::Postgres
    end

    def usage
      puts "Must specify migration direction: up or down"
      exit 1
    end
  end
end

Migrations::CLI.new.run
