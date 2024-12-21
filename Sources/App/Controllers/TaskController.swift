//
//  File 2.swift
//  TaskApp
//
//  Created by Ibrahim Arogundade on 12/11/24.
//

import Vapor
import Fluent


struct TaskController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
           // Group all routes under /api/tasks
           let tasks = routes.grouped("api", "tasks")
           
           // Auth middleware would go here in production
           // let protected = tasks.grouped(UserAuthMiddleware())
           
           // GET /api/tasks - Retrieve all tasks
           tasks.get(use: getAllTasks)
           
           // GET /api/tasks/:taskId - Retrieve a specific task by ID
           tasks.get(":taskId", use: getTask)
           
           // POST /api/tasks - Create a new task
           tasks.post(use: createTask)
           
           // PUT /api/tasks/:taskId - Update an existing task
           tasks.put(":taskId", use: updateTask)
           
           // DELETE /api/tasks/:taskId - Delete a task
           tasks.delete(":taskId", use: deleteTask)
           
           // Additional functionality
           
           // GET /api/tasks/list/:listId - Get all tasks for a specific list
           tasks.get("list", ":listId", use: getTasksByList)
           
           // PATCH /api/tasks/:taskId/complete - Toggle task completion status
           tasks.patch(":taskId", "complete", use: toggleTaskComplete)
       }
    
    // Get all tasks
    @Sendable
    func getAllTasks(req: Request) async throws -> [TaskDTO.Public] {
        let tasks = try await Task.query(on: req.db)
            .with(\.$list)
            .all()
        return tasks.map { $0.toDTO() }
    }
    
    @Sendable
        func getTask(req: Request) async throws -> TaskDTO.Public {
            guard let task = try await Task.find(req.parameters.get("taskId"), on: req.db) else {
                throw Abort(.notFound, reason: "Task not found")
            }
            try await task.$list.load(on: req.db)
            return task.toDTO()
        }
        
        // Create task
        @Sendable
        func createTask(req: Request) async throws -> TaskDTO.Public {
            let createDTO = try req.content.decode(TaskDTO.Create.self)
            guard let listId = req.parameters.get("listId", as: Int64.self) else {
                throw Abort(.badRequest, reason: "List ID is required")
            }
            
            let task = Task(
                listID: listId,
                title: createDTO.title,
                description: createDTO.description
            )
            
            try await task.save(on: req.db)
            return task.toDTO()
        }
        
        // Update task
        @Sendable
        func updateTask(req: Request) async throws -> TaskDTO.Public {
            guard let task = try await Task.find(req.parameters.get("taskId"), on: req.db) else {
                throw Abort(.notFound)
            }
            
            let updateDTO = try req.content.decode(TaskDTO.self)
            
            task.title = updateDTO.title
            task.description = updateDTO.description
            
            try await task.save(on: req.db)
            return task.toDTO()
        }
        
        // Delete task
        @Sendable
        func deleteTask(req: Request) async throws -> HTTPStatus {
            guard let task = try await Task.find(req.parameters.get("taskId"), on: req.db) else {
                throw Abort(.notFound)
            }
            try await task.delete(on: req.db)
            return .noContent
        }
        
        // Get tasks by list
        @Sendable
        func getTasksByList(req: Request) async throws -> [TaskDTO.Public] {
            guard let listId = req.parameters.get("listId", as: Int64.self) else {
                throw Abort(.badRequest)
            }
            
            let tasks = try await Task.query(on: req.db)
                .filter(\.$list.$id == listId)
                .all()
            
            return tasks.map { $0.toDTO() }
        }
        
    
    
        // Toggle task completion status
        @Sendable
        func toggleTaskComplete(req: Request) async throws -> TaskDTO.Public {
            guard let task = try await Task.find(req.parameters.get("taskId"), on: req.db) else {
                throw Abort(.notFound)
            }
            
            task.completed.toggle()
            try await task.save(on: req.db)
            return task.toDTO()
        }
    
}
