//
//  File.swift
//  TaskApp
//
//  Created by Ibrahim Arogundade on 2/13/25.
//


import Vapor
import MailgunProvider

struct EmailService {
    let app: Application
    let mailgun: MailgunProvider
    
    init(app: Application) throws {
        self.app = app
        
        guard let mailgunApiKey = Environment.get("MAILGUN_API_KEY"),
              let mailgunDomain = Environment.get("MAILGUN_DOMAIN") else {
            throw Abort(.internalServerError, reason: "Mailgun configuration is missing")
        }
        
        self.mailgun = MailgunProvider(apiKey: mailgunApiKey, domain: mailgunDomain)
        try app.mailgun.use(self.mailgun)
    }
    
    func sendPasswordResetEmail(to email: String, token: String) async throws {
        let emailContent = """
        Hello,
        
        You have requested to reset your password. Please use the following token to reset your password:
        
        \(token)
        
        If you did not request a password reset, please ignore this email.
        
        This token will expire in 1 hour.
        
        Best regards,
        Your App Team
        """
        
        let message = MailgunMessage(
            from: "noreply@yourdomain.com",
            to: email,
            subject: "Password Reset Token",
            text: emailContent
        )
        
        do {
            try await mailgun.send(message)
            app.logger.info("Password reset token sent to \(email)")
        } catch {
            app.logger.error("Failed to send password reset token: \(error)")
            throw Abort(.internalServerError, reason: "Failed to send password reset token")
        }
    }
}
