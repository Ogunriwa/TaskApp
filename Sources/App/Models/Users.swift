//
//  File.swift
//  TaskApp
//
//  Created by Ibrahim Arogundade on 12/11/24.
//

import Foundation
import Fluent
import Vapor

final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Field(key: "username")
    var username: String
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Children(for: \.$user)
    var lists: [TaskList]
    
    init() { }
    
    init(id: Int64? = nil, username: String, email: String, passwordHash: String) {
        self.id = id
        self.username = username
        self.email = email
        self.passwordHash = passwordHash
    }
    
    func userDTO() -> UserDTO.Public {
        .init(id: self.id, username: self.username, email: self.email)
    }
}

