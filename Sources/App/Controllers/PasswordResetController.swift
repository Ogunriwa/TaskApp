//
//  Untitled.swift
//  TaskApp
//
//  Created by Ibrahim Arogundade on 2/13/25.
//

import Vapor
import Fluent

struct PasswordResetController: RouteCollection {
    let emailService: EmailService
    
    init(emailService: EmailService) {
        self.emailService = emailService
    }
    
    func boot(routes: RoutesBuilder) throws {
        let passwordReset = routes.grouped("password-reset")
        passwordReset.post("request", use: requestReset)
        passwordReset.post("verify-token", use: verifyToken)
        passwordReset.post("reset", use: resetPassword)
    }
    
    // Step 1: Request password reset
    func requestReset(req: Request) async throws -> PasswordResetResponseDTO {
        try RequestResetDTO.validate(content: req)
        let dto = try req.content.decode(RequestResetDTO.self)
        
        // Check if user exists
        guard let _ = try await User.query(on: req.db)
            .filter(\.$email == dto.email)
            .first() else {
            // For security reasons, we return success even if the email doesn't exist
            return PasswordResetResponseDTO(message: "If an account exists with this email, you will receive a password reset token.")
        }
        
        // Generate random token
        let token = String(UUID().uuidString.prefix(6))
        
        // Create password reset record
        let passwordReset = PasswordReset(
            email: dto.email,
            token: token,
            expiresAt: Date().addingTimeInterval(3600) // Token expires in 1 hour
        )
        try await passwordReset.save(on: req.db)
        
        // Send email with token
        do {
            try await emailService.sendPasswordResetEmail(to: dto.email, token: token)
            req.logger.info("Password reset token sent to \(dto.email)")
        } catch {
            req.logger.error("Failed to send password reset token: \(error)")
            throw Abort(.internalServerError, reason: "Failed to send password reset token")
        }
        
        return PasswordResetResponseDTO(message: "If an account exists with this email, you will receive a password reset token.")
    }
    
    // Step 2: Verify token
    func verifyToken(req: Request) async throws -> PasswordResetResponseDTO {
        try VerifyTokenDTO.validate(content: req)
        let dto = try req.content.decode(VerifyTokenDTO.self)
        
        guard let resetRequest = try await PasswordReset.query(on: req.db)
            .filter(\.$email == dto.email)
            .filter(\.$token == dto.token)
            .filter(\.$expiresAt > Date())
            .first() else {
            throw Abort(.badRequest, reason: "Invalid or expired token")
        }
        
        return PasswordResetResponseDTO(message: "Token verified successfully")
    }
    
    // Step 3: Reset password
    func resetPassword(req: Request) async throws -> PasswordResetResponseDTO {
        try ResetPasswordDTO.validate(content: req)
        let dto = try req.content.decode(ResetPasswordDTO.self)
        
        guard let resetRequest = try await PasswordReset.query(on: req.db)
            .filter(\.$email == dto.email)
            .filter(\.$token == dto.token)
            .filter(\.$expiresAt > Date())
            .first() else {
            throw Abort(.badRequest, reason: "Invalid or expired token")
        }
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == dto.email)
            .first() else {
            throw Abort(.notFound, reason: "User not found")
        }
        
        // Update password
        user.password = try await req.password.hash(dto.newPassword)
        try await user.save(on: req.db)
        
        // Delete the used reset token
        try await resetRequest.delete(on: req.db)
        
        return PasswordResetResponseDTO(message: "Password has been reset successfully")
    }
}
