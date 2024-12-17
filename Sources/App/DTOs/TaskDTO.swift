//
//  File.swift
//  TaskApp
//
//  Created by Ibrahim Arogundade on 12/11/24.
// Sources/App/DTOs/TaskDTO.swift

import Foundation

import Vapor
import Fluent

struct TaskDTO: Content {
    
    let id: Int64?
    var title: String
    let description: String
    let completed: Bool
    
    struct Create: Content {
        var title: String
        var description: String
    }
    
    struct Public: Content {
        let id: Int64?
        let title: String?
        let description: String?
        let completed: Bool?
        let listId: Int64?
        
    }
}
