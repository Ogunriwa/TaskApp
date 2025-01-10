//
//  File.swift
//  TaskApp
//
//  Created by Ibrahim Arogundade on 12/22/24.
//

import Foundation
import Fluent


struct CreateUserToken: AsyncMigration {
    
    var name: String { "CreateUserToken" }
    
    func prepare(on database: Database) async throws {
        
        try await database.schema("user_tokens")
            .field("id", .int64, .identifier(auto: true))
            .field("token", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id"))
            .unique(on: "token")
            .create()
            
    }
    
    func revert(on database: Database) async throws {
        
        try await database.schema("user_tokens").delete()
    }
}
