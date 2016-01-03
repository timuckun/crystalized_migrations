require "./statements/*"

module Migrations
  alias RunnableMigrations = Statements::CreateTable | Statements::DropTable | Statements::AddColumn
end
