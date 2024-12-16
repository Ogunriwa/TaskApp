//
//  File 2.swift
//  TaskApp
//
//  Created by Ibrahim Arogundade on 12/11/24.
//

import Foundation
// Sources/App/Models/TaskList.swift
import Fluent
import Vapor

final class TaskList: Model, Content, @unchecked Sendable {
    static let schema = "lists"
    
    @ID(custom: .id, generatedBy: .database)
    var id: Int64?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$list)
    var tasks: [Task]
    
    init() { }
    
    init(id: Int64? = nil, userID: Int64, name: String) {
        self.id = id
        self.$user.id = userID
        self.name = name
    }
}

extension TaskList {
    func listDTO() -> TaskListDTO.Public {
        .init(
            id: self.id!,
            name: self.name,
            userId: self.$user.id
        )
    }
}
