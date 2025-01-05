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


extension User {
    
    struct Create: Content {
        var username: String
        var email: String
        var password: String
        var confirmPassword: String
    }
}

extension User.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self, is: !.empty)
        validations.add("username", as: String.self, is: !.empty && .count(3...) && .alphanumeric)  // Username validation
        validations.add("password", as: String.self, is: .count(8...))
    }
}



extension User: ModelAuthenticatable {
    
    
    
    static let usernameKey: KeyPath<User, Field<String>> = \User.$username
    static let passwordHashKey: KeyPath<User, Field<String>> = \User.$passwordHash
    
    
    func verify(password: String) throws -> Bool {
        
        try Bcrypt.verify(password, created: self.passwordHash)
        
    }
    
    
}

extension User {
    
    func genToken() throws -> UserToken {
        
        try.init(
            token: [UInt8].random(count:16).base64,
            userID: self.requireID()
        )
    }
}

    

