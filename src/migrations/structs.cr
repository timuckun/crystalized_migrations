require "./statements/*"

module Migrations
  alias RunnableMigrations = Statements::CreateTable | Statements::DropTable
end
