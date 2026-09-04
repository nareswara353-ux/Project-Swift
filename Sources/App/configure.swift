import Vapor
import Fluent
import FluentPostgresDriver
import Infrastructure
import Domain
import Core

public func configure(_ app: Application) async throws {
    let config = try AppConfiguration.load()
    
    app.databases.use(
        .postgres(
            url: config.databaseURL,
            maxConnections: 10
        ),
        as: .psql
    )
    
    app.migrations.add(CreateUserMigration())
    app.migrations.add(CreateTaskMigration())
    
    try await app.autoMigrate()
    
    try routes(app)
}
