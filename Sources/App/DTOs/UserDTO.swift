// Sources/App/DTOs/UserDTO.swift
import Vapor
import Fluent

struct UserDTO: Content {
    
    var id: Int64?
    var username: String?
    var email: String?
    var passwordHash: String?
    
    
    struct Create: Content {
        let username: String?
        let email: String?
        let password: String?
    }
    
    struct Public: Content {
        let id: Int64?
        let username: String?
        let email: String?
        
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
