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
          
        let protected = routes.grouped(UserToken.authenticator(), User.guardMiddleware())
        let tasks = protected.grouped("tasks")
           // Auth middleware would go here in production
           // let protected = tasks.grouped(UserAuthMiddleware())
           
           // GET /api/tasks - Retrieve all tasks
           tasks.get(use: getAllTasks)
           
           // GET /api/tasks/:taskId - Retrieve a specific task by ID
           tasks.get(":taskId", use: getTask)
           
           // POST /api/tasks - Create a new task
           tasks.post(use: createTask)
        
            // PATCH /api/tasks/:taskId/complete - Toggle task completion status
           tasks.patch(":taskId", "toggle", use: toggleComplete)
        
            
           // PUT /api/tasks/:taskId - Update an existing task
           tasks.put(":taskId", use: updateTask)
           
           // DELETE /api/tasks/:taskId - Delete a task
           tasks.delete(":taskId", use: deleteTask)
        
    }
    
    // Get all tasks
    @Sendable
    func getAllTasks(req: Request) async throws -> [TaskDTO.Public] {
        let user = try req.auth.require(User.self)
        
        guard let taskList = try await TaskList.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .first() else {
            throw Abort(.notFound, reason: "Task list not found")
        }
        
        let tasks = try await Task.query(on: req.db)
            .filter(\.$list.$id == taskList.id!)
            .all()
        
        return tasks.map { $0.toDTO() }
    }
    
    
    
    // Get single tasks
    
    @Sendable
        func getTask(req: Request) async throws -> TaskDTO.Public {
            let user = try req.auth.require(User.self)
            
            guard let taskId = req.parameters.get("taskId", as: Int64.self) else {
                throw Abort(.badRequest, reason: "Invalid task ID")
            }
            
            guard let task = try await Task.query(on: req.db)
                .filter(\.$id == taskId)
                .join(TaskList.self, on: \Task.$list.$id == \TaskList.$id)
                .filter(TaskList.self, \.$user.$id == user.id!)
                .first() else {
                throw Abort(.notFound, reason: "Task not found or unauthorized")
            }
            
            return task.toDTO()
    }
        
    
    // Create task
    
    @Sendable
    func createTask(req: Request) async throws -> TaskDTO.Public {
        // Get authenticated user
        let user = try req.auth.require(User.self)
        
        // Get user's task list (they only have one)
        guard let taskList = try await TaskList.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .first() else {
            throw Abort(.notFound, reason: "Task list not found")
        }
        
        // Create and save the task
        let createDTO = try req.content.decode(TaskDTO.Create.self)
        let task = Task(
            listID: taskList.id!,
            title: createDTO.title,
            description: createDTO.description
        )
        
        try await task.save(on: req.db)
        return task.toDTO()
    }
        
        
        // Update task
    @Sendable
       func updateTask(req: Request) async throws -> TaskDTO.Public {
           let user = try req.auth.require(User.self)
           
           guard let taskId = req.parameters.get("taskId", as: Int64.self) else {
               throw Abort(.badRequest, reason: "Invalid task ID")
           }
           
           // Verify task exists and belongs to user
           guard let task = try await Task.query(on: req.db)
               .filter(\.$id == taskId)
               .join(TaskList.self, on: \Task.$list.$id == \TaskList.$id)
               .filter(TaskList.self, \.$user.$id == user.id!)
               .first() else {
               throw Abort(.notFound, reason: "Task not found or unauthorized")
           }
           
           let updateDTO = try req.content.decode(TaskDTO.Update.self)
           
           // Update task properties
           if let title = updateDTO.title {
               task.title = title
           }
           if let description = updateDTO.description {
               task.description = description
           }
           
           try await task.save(on: req.db)
           return task.toDTO()
       }
       
    
    // Delete task
    @Sendable
        func deleteTask(req: Request) async throws -> HTTPStatus {
            let user = try req.auth.require(User.self)
            
            guard let taskId = req.parameters.get("taskId", as: Int64.self) else {
                throw Abort(.badRequest, reason: "Invalid task ID")
            }
            
            // Verify task exists and belongs to user
            guard let task = try await Task.query(on: req.db)
                .filter(\.$id == taskId)
                .join(TaskList.self, on: \Task.$list.$id == \TaskList.$id)
                .filter(TaskList.self, \.$user.$id == user.id!)
                .first() else {
                throw Abort(.notFound, reason: "Task not found or unauthorized")
            }
            
            try await task.delete(on: req.db)
            return .noContent
    }
    
    
    


    // Toggle task completion status
    @Sendable
        func toggleComplete(req: Request) async throws -> TaskDTO.Public {
            let user = try req.auth.require(User.self)
            
            guard let taskId = req.parameters.get("taskId", as: Int64.self) else {
                throw Abort(.badRequest, reason: "Invalid task ID")
            }
            
            guard let task = try await Task.query(on: req.db)
                .filter(\.$id == taskId)
                .join(TaskList.self, on: \Task.$list.$id == \TaskList.$id)
                .filter(TaskList.self, \.$user.$id == user.id!)
                .first() else {
                throw Abort(.notFound, reason: "Task not found or unauthorized")
            }
            
            task.completed.toggle()
            try await task.save(on: req.db)
            return task.toDTO()
    }

    
}


