require "./migrations/*"

module Migrations
  class CLI
    def self.run
      args = ARGV
      case
      when args.size < 1
        usage
      when args[0] == "up"
        Migrator.migrate
      when args[0] == "down"
        Migrator.rewind
      else
        usage
      end
    end

    def self.usage
      puts "Must specify migration direction: up or down"
      exit 1
    end
  end
end

Migrations::CLI.run
