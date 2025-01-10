//
//  File.swift
//  TaskApp
//
//  Created by Ibrahim Arogundade on 12/22/24.
//

import Foundation
import Vapor
import Fluent

final class UserToken : Model, Content, @unchecked Sendable {
    
    static let schema = "user_tokens"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Field(key: "token")
    var token: String
    
    @Parent(key: "user_id")
    var user: User
    
    init() {}
    
    // Initializes it
    init(id: Int64? = nil, token: String, userID: User.IDValue) {
        self.id = id
        self.token = token
        self.$user.id = userID
    }
    
}
extension UserToken: ModelTokenAuthenticatable {
    
    static let valueKey = \UserToken.$token
    static let userKey = \UserToken.$user
    
    var isValid: Bool {
        true
    }
}
