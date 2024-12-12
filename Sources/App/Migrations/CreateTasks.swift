// Sources/App/Migrations/CreateTask.swift
import Fluent

struct CreateTask: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("tasks")
            .field("id", .int64, .identifier(auto: true))
            .field("list_id", .int64, .required, .references("lists", "id"))
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("completed", .bool, .required, .custom("DEFAULT FALSE"))
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("tasks").delete()
    }
}
