import Vapor
import Fluent
import FluentPostgresDriver
import Infrastructure
import Core
import Domain

func configure(_ app: Application) async throws {
    let config = try AppConfiguration.load()
    
    app.databases.use(.postgres(url: config.databaseURL), as: .psql)
    
    app.migrations.add(CreateUserMigration())
    app.migrations.add(CreateTaskMigration())
    
    try await app.autoMigrate()
    
    app.middleware.use(APIErrorMiddleware())
    app.middleware.use(RequestLoggerMiddleware())
    
    try app.register(collection: HealthController())
    try app.register(collection: AuthController())
    try app.register(collection: TaskController())
}
