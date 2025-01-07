//
//  File.swift
//  TaskApp
//
//  Created by Ibrahim Arogundade on 12/11/24.
//

import Foundation
import Vapor
import Fluent


struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        let users = routes.grouped("signin")
        users.post(use: self.create)
        
        let user_protected = routes.grouped(User.authenticator())
        user_protected.post("login",  use: self.login)
        
        let user_access = routes.grouped(UserToken.authenticator(), User.guardMiddleware())
        
        user_access.get("user", use: self.getCurrentUser)
        
        users.get(":userID", "tasks", use: getUserTasks)
    }


    @Sendable
    func create(req: Request) async throws -> UserDTO.Public {
        
        //Validate the log in
        try User.Create.validate(content:req)
        
         //Take the user inputted values and map them to User.Create.self
        let createUser = try req.content.decode(User.Create.self)
        
        if try await User.query(on: req.db)
                    .filter(\.$username == createUser.username)
                    .first() != nil {
                    throw Abort(.conflict, reason: "Username already taken")
        }
        
        //Confirm the password
        guard createUser.confirmPassword == createUser.password else {
            throw Abort(.badRequest, reason: "Passwords do not match")
        }
        
        return try await req.db.transaction { database in
                    // Create user
                    let user = User(
                        username: createUser.username,
                        email: createUser.email,
                        passwordHash: try Bcrypt.hash(createUser.password)
                    )
                    try await user.save(on: database)
                    
                    // Create their single task list automatically
                    let taskList = TaskList(
                        userID: user.id!,
                        name: "My Tasks"  // Default name for the user's task list
                    )
                    try await taskList.save(on: database)
                    
                    return UserDTO.Public(
                        user: user,             // Pass the user object
                        taskListId: taskList.id
                    )
        }
        
    }
    
    @Sendable
    func login(req: Request) async throws -> UserToken {
        
        do {
            
            // User.self access requires authorization
            let credentials = try req.content.decode(LoginCred.self)
            guard let user = try await User.query(on: req.db)
                .filter(\.$email == credentials.email)
                .first() else {
                    throw Abort(.unauthorized, reason: "Invalid credentials")
                }
            
            guard try user.verify(password:credentials.password) else {
                
                throw Abort(.unauthorized, reason: "Invalid password")
            }
            
            
            let token = try user.genToken()
            
            //Save the token
            try await token.save(on: req.db)
            
            // return the token
            return token
        }
        
        catch {
            throw Abort(.unauthorized, reason: "Not authenticated")
        }
    }
    
    
    
    
    // GET /tasks?userID=1
    
    
    
}

extension UserController {
    
    
    @Sendable
        func getCurrentUser(req: Request) async throws -> UserDTO.Public {
            let user = try req.auth.require(User.self)
            return UserDTO.Public(
                user:user
            )
        }
        
        // Get user's tasks
        @Sendable
        func getUserTasks(req: Request) async throws -> [TaskDTO.Public] {
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
}

