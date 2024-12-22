import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "ibrahimarogundade",
        password: Environment.get("DATABASE_PASSWORD") ?? "94016427",
        database: Environment.get("DATABASE_NAME") ?? "taskapp",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)

    app.migrations.add(CreateUser())       // Create users table first
    app.migrations.add(CreateTaskList())   // Now safe to reference users
    app.migrations.add(CreateTask())       // Other tables
    // register routes
    try routes(app)
    
}
