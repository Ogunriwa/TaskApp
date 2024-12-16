//
//  File 2.swift
//  TaskApp
//
//  Created by Ibrahim Arogundade on 12/11/24.
//

import Foundation
import Vapor
import Fluent

struct TaskListDTO: Content {
    
    var tasks: [Task]
    struct Create: Content {
        let name: String
    }
    
    struct Public: Content {
        let id: Int64
        let name: String
        let userId: Int64
        let tasks: [Task]
        
    }
    
}
