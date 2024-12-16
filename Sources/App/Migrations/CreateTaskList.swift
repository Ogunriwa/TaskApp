//
//  File.swift
//  TaskApp
//
//  Created by Ibrahim Arogundade on 12/11/24.
//

import Fluent

struct CreateTaskList: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("lists")
            .field("id", .int64, .identifier(auto: true))
            .field("user_id", .int64, .required, .references("users", "id"))
            .field("name", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("lists").delete()
    }
}
