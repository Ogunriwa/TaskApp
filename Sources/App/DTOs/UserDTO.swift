// Sources/App/DTOs/UserDTO.swift
import Vapor
import Fluent

struct UserDTO: Content {
    var id: Int64?
    var name: String?
    var username: String?
    var email: String?
    var passwordHash: String?
    
    // For creating a new user
    struct Create: Content {
        let username: String?
        let email: String?
        let password: String?
        let confirmPassword: String? // If you want password confirmation
    }
    
    // For public responses
    struct Public: Content {
        let id: Int64?
        let username: String
        let email: String
        let taskListId: Int64?  // Added this for task list relationship
        
        // Initialize with user and taskList
        init(user: User, taskListId: Int64? = nil) {
            self.id = user.id
            self.username = user.username
            self.email = user.email
            self.taskListId = taskListId
        }
    }
}

extension UserDTO {
    func userToModel() -> User {
        let user = User()
        
        if let username = self.username {
            user.username = username
        }
        
        if let email = self.email {
            user.email = email
        }
        
        if let passwordHash = self.passwordHash {
            user.passwordHash = passwordHash
        }
        
        return user
    }
}
